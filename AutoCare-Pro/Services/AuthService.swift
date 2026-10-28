//
//  AuthService.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

struct UserProfile {
    let fullName: String
    let email: String
    let phoneNumber: String
    let profilePhotoBase64: String?
}

final class AuthService: ObservableObject {

    @Published private(set) var user: FirebaseAuth.User?
    @Published private(set) var isCreatingAccount = false

    private let auth = Auth.auth()
    private let database = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        user = auth.currentUser

        authListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self else { return }

        
                guard !self.isCreatingAccount else { return }

                self.user = user
            }
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
        guard !isCreatingAccount else { return }


        isCreatingAccount = true

        let cleanName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        auth.createUser(
            withEmail: cleanEmail,
            password: password
        ) { [weak self] result, error in

            guard let self else { return }

            if let error {
                self.finishRegistration(
                    error: error.localizedDescription,
                    signOut: false,
                    completion: completion
                )
                return
            }

            guard let newUser = result?.user else {
                self.finishRegistration(
                    error: "Could not create your account.",
                    signOut: false,
                    completion: completion
                )
                return
            }

            let changeRequest = newUser.createProfileChangeRequest()
            changeRequest.displayName = cleanName

            changeRequest.commitChanges { [weak self] error in
                guard let self else { return }

                if let error {
                    self.finishRegistration(
                        error: error.localizedDescription,
                        signOut: true,
                        completion: completion
                    )
                    return
                }

                self.database.collection("users")
                    .document(newUser.uid)
                    .setData([
                        "fullName": cleanName,
                        "email": cleanEmail,
                        "phoneNumber": cleanPhone,
                        "createdAt": FieldValue.serverTimestamp()
                    ]) { [weak self] error in

                        guard let self else { return }

                        if let error {
                            self.finishRegistration(
                                error: error.localizedDescription,
                                signOut: true,
                                completion: completion
                            )
                            return
                        }


                        self.finishRegistration(
                            error: nil,
                            signOut: true,
                            completion: completion
                        )
                    }
            }
        }
    }

    private func finishRegistration(
        error: String?,
        signOut: Bool,
        completion: @escaping (String?) -> Void
    ) {
        var finalError = error

        if signOut {
            do {
                try auth.signOut()
            } catch {
                let signOutMessage =
                    "Could not sign out after registration: \(error.localizedDescription)"

                if let existingError = finalError {
                    finalError = "\(existingError) \(signOutMessage)"
                } else {
                    finalError = signOutMessage
                }
            }
        }

        DispatchQueue.main.async {
            self.user = self.auth.currentUser
            self.isCreatingAccount = false
            completion(finalError)
        }
    }



    func signIn(
        email: String,
        password: String,
        completion: @escaping (String?) -> Void
    ) {
        auth.signIn(
            withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        ) { _, error in
            completion(error?.localizedDescription)
        }
    }


    func fetchUserProfile(
        completion: @escaping (Result<UserProfile, Error>) -> Void
    ) {
        guard let currentUser = auth.currentUser else {
            completion(.failure(
                NSError(
                    domain: "AutoCare",
                    code: 401,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Please sign in again."
                    ]
                )
            ))
            return
        }

        database.collection("users")
            .document(currentUser.uid)
            .getDocument { snapshot, error in

                if let error {
                    completion(.failure(error))
                    return
                }

                let data = snapshot?.data() ?? [:]

                let profile = UserProfile(
                    fullName: data["fullName"] as? String
                        ?? currentUser.displayName
                        ?? "",
                    email: currentUser.email ?? "",
                    phoneNumber: data["phoneNumber"] as? String ?? "",
                    profilePhotoBase64: data["profilePhotoBase64"] as? String
                )

                completion(.success(profile))
            }
    }


    func updateUserProfile(
        fullName: String,
        phoneNumber: String,
        profilePhotoBase64: String? = nil,
        completion: @escaping (String?) -> Void
    ) {
        guard let currentUser = auth.currentUser else {
            completion("Please sign in again.")
            return
        }

        let cleanName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            completion("Full name cannot be empty.")
            return
        }

        guard !cleanPhone.isEmpty else {
            completion("Phone number cannot be empty.")
            return
        }

        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = cleanName

        changeRequest.commitChanges { [weak self] error in
            guard let self else { return }

            if let error {
                completion(error.localizedDescription)
                return
            }

            self.database.collection("users")
                .document(currentUser.uid)
                .setData([
                    "fullName": cleanName,
                    "phoneNumber": cleanPhone,
                    "profilePhotoBase64": profilePhotoBase64 ?? ""
                ], merge: true) { error in
                    completion(error?.localizedDescription)
                }
        }
    }


    func signOut(completion: @escaping (String?) -> Void) {
        do {
            try auth.signOut()

            DispatchQueue.main.async {
                self.user = nil
                completion(nil)
            }
        } catch {
            completion(error.localizedDescription)
        }
    }


    func deleteAccount(
        password: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let currentUser = auth.currentUser,
              let email = currentUser.email else {
            completion("Please sign in again.")
            return
        }

        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )

        currentUser.reauthenticate(with: credential) { [weak self] _, error in
            guard let self else { return }

            if let error {
                completion(
                    "Could not verify your password. \(error.localizedDescription)"
                )
                return
            }

            let profileRef = self.database.collection("users")
                .document(currentUser.uid)

            profileRef.getDocument { snapshot, error in
                if let error {
                    completion(error.localizedDescription)
                    return
                }

                let oldProfile = snapshot?.data()

                profileRef.delete { error in
                    if let error {
                        completion(error.localizedDescription)
                        return
                    }

                    currentUser.delete { error in
                        if let error {
                            if let oldProfile {
                                profileRef.setData(oldProfile) { _ in
                                    completion(error.localizedDescription)
                                }
                            } else {
                                completion(error.localizedDescription)
                            }
                            return
                        }

                        DispatchQueue.main.async {
                            self.user = nil
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
