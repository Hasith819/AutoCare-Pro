//
//  AuthService.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthService: ObservableObject {

    @Published private(set) var user: FirebaseAuth.User?

    private let auth = Auth.auth()
    private let database = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        user = auth.currentUser

        authListener = auth.addStateDidChangeListener {
            [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let authListener {
            auth.removeStateDidChangeListener(authListener)
        }
    }

    func createAccount(
        fullName: String,
        email: String,
        password: String,
        phoneNumber: String,
        completion: @escaping (String?) -> Void
    ) {
        let cleanName = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanPhone = phoneNumber.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        auth.createUser(
            withEmail: cleanEmail,
            password: password
        ) { [weak self] result, error in

            if let error {
                completion(Self.friendlyMessage(for: error))
                return
            }

            guard let self, let newUser = result?.user else {
                completion("Could not create your account. Please try again.")
                return
            }

            let request = newUser.createProfileChangeRequest()
            request.displayName = cleanName

            request.commitChanges { [weak self] error in
                if let error {
                    completion(Self.friendlyMessage(for: error))
                    return
                }

                guard let self else {
                    completion("Account created, but the profile could not be saved.")
                    return
                }

                self.database.collection("users")
                    .document(newUser.uid)
                    .setData([
                        "fullName": cleanName,
                        "email": cleanEmail,
                        "phoneNumber": cleanPhone,
                        "createdAt": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error {
                            completion(
                                "Your account was created, but saving your profile failed. Please contact support before trying to register again. Details: \(error.localizedDescription)"
                            )
                            return
                        }

                        completion(nil)
                    }
            }
        }
    }

    func signIn(
        email: String,
        password: String,
        completion: @escaping (String?) -> Void
    ) {
        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        auth.signIn(
            withEmail: cleanEmail,
            password: password
        ) { _, error in
            if let error {
                completion(Self.friendlyMessage(for: error))
            } else {
                completion(nil)
            }
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    private static func friendlyMessage(for error: Error) -> String {
        let authError = error as NSError

        guard authError.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: authError.code)
        else {
            return error.localizedDescription
        }

        switch code {
        case .emailAlreadyInUse:
            return "This email is already registered. Please sign in."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Your password is too weak. Please choose a stronger password."
        case .wrongPassword, .invalidCredential:
            return "Email or password is incorrect."
        case .userNotFound:
            return "No account was found for this email."
        case .networkError:
            return "Network error. Check your internet connection."
        case .tooManyRequests:
            return "Too many attempts. Please wait and try again."
        default:
            return error.localizedDescription
        }
    }
}
