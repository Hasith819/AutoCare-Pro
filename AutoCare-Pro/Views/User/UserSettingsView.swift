//
//  UserSettingsView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import SwiftUI
import PhotosUI

struct UserSettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var profilePhotoBase64 = ""
    @State private var selectedProfileItem: PhotosPickerItem?

    @State private var faceIdEnabled = true
    @State private var notificationsEnabled = true

    @State private var isLoading = true
    @State private var isSaving = false
    @State private var isSigningOut = false
    @State private var isDeleting = false

    @State private var showMessage = false
    @State private var message = ""

    @State private var showDeleteConfirmation = false
    @State private var deletePassword = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        profileHeader

                   
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("ACCOUNT DETAILS")

                            VStack(spacing: 14) {
                                settingTextField(
                                    title: "Full Name",
                                    text: $name
                                )

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Email Address")
                                        .font(.caption2)
                                        .foregroundStyle(
                                            AppColors.secondaryLabel
                                        )

                                    Text(email.isEmpty ? "Loading..." : email)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(
                                            AppColors.secondaryText
                                        )
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                }
                                .padding(16)
                                .background(AppColors.inputBackground)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )

                                settingTextField(
                                    title: "Phone Number",
                                    text: $phone
                                )
                            }
                            .padding(.horizontal, 20)

                        }

                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("SECURITY & PREFERENCES")

                            VStack(spacing: 12) {
                                Toggle(isOn: $faceIdEnabled) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "faceid")
                                            .foregroundStyle(AppColors.accent)

                                        Text("Face ID Protection")
                                            .font(.subheadline)
                                            .foregroundStyle(
                                                AppColors.primaryText
                                            )
                                    }
                                }
                                .tint(AppColors.accent)
                                .padding(16)
                                .background(AppColors.inputBackground)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )

                                Toggle(isOn: $notificationsEnabled) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "bell.fill")
                                            .foregroundStyle(AppColors.accent)

                                        Text("Service Reminders")
                                            .font(.subheadline)
                                            .foregroundStyle(
                                                AppColors.primaryText
                                            )
                                    }
                                }
                                .tint(AppColors.accent)
                                .padding(16)
                                .background(AppColors.inputBackground)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                            }
                            .padding(.horizontal, 20)
                        }


                        Button(action: signOut) {
                            HStack {
                                if isSigningOut {
                                    ProgressView()
                                        .tint(.red)
                                }

                                Text(
                                    isSigningOut
                                    ? "Signing Out..."
                                    : "Sign Out"
                                )
                                .font(.headline)
                                .fontWeight(.bold)
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(isSigningOut || isDeleting)
                        .padding(.horizontal, 20)

                        Button {
                            deletePassword = ""
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                if isDeleting {
                                    ProgressView()
                                        .tint(.red)
                                }

                                Image(systemName: "trash")

                                Text(
                                    isDeleting
                                    ? "Deleting Account..."
                                    : "Delete Account"
                                )
                                .font(.headline)
                                .fontWeight(.bold)
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        Color.red.opacity(0.6),
                                        lineWidth: 1
                                    )
                            }
                        }
                        .disabled(isDeleting || isSigningOut)
                        .padding(.horizontal, 20)

                        Spacer()
                            .frame(height: 30)
                    }
                    .padding(.vertical, 16)
                }

                if isLoading {
                    ProgressView("Loading profile...")
                        .tint(AppColors.accent)
                        .foregroundStyle(AppColors.primaryText)
                }
            }
            .navigationTitle("User Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSaving ? "Saving..." : "Done") {
                        saveProfile()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.accent)
                    .disabled(isSaving || isLoading || isSigningOut || isDeleting)
                }
            }
            .task {
                loadProfile()
            }
            .alert("AutoCare-Pro", isPresented: $showMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(message)
            }
            .alert(
                "Delete Account?",
                isPresented: $showDeleteConfirmation
            ) {
                SecureField("Enter your current password", text: $deletePassword)

                Button("Delete Account", role: .destructive) {
                    deleteAccount()
                }

                Button("Cancel", role: .cancel) {
                    deletePassword = ""
                }
            } message: {
                Text(
                    "This permanently deletes your Firebase account and profile. This action cannot be undone."
                )
            }
        }
    }


    private var profileHeader: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedProfileItem, matching: .images) {
                ZStack {
                    if let profileImage = Base64ImageStorage.decode(profilePhotoBase64) {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(AppColors.accent)
                            .frame(width: 90, height: 90)
                    }
                }
            }
            .onChange(of: selectedProfileItem) { _, newItem in
                guard let newItem else { return }

                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let encoded = Base64ImageStorage.encode(image) {
                        await MainActor.run {
                            profilePhotoBase64 = encoded
                        }
                    }
                }
            }

            Text(name.isEmpty ? "Your Profile" : name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)

            Text(email)
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }


    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(AppColors.secondaryLabel)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
    }


    private func settingTextField(
        title: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryLabel)

            TextField("", text: text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primaryText)
                .textInputAutocapitalization(
                    title == "Full Name" ? .words : .never
                )
                .autocorrectionDisabled(title != "Full Name")
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }


    private func loadProfile() {
        isLoading = true

        authService.fetchUserProfile { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let profile):
                    name = profile.fullName
                    email = profile.email
                    phone = profile.phoneNumber
                    profilePhotoBase64 = profile.profilePhotoBase64 ?? ""

                case .failure(let error):
                    message = "Could not load your profile: \(error.localizedDescription)"
                    showMessage = true
                }
            }
        }
    }


    private func saveProfile() {
        guard !isSaving else { return }

        isSaving = true

        authService.updateUserProfile(
            fullName: name,
            phoneNumber: phone,
            profilePhotoBase64: profilePhotoBase64.isEmpty ? nil : profilePhotoBase64
        ) { error in
            DispatchQueue.main.async {
                isSaving = false

                if let error {
                    message = "Could not save changes: \(error)"
                    showMessage = true
                } else {
                    dismiss()
                }
            }
        }
    }


    private func signOut() {
        isSigningOut = true

        authService.signOut { error in
            DispatchQueue.main.async {
                isSigningOut = false

                if let error {
                    message = "Could not sign out: \(error)"
                    showMessage = true
                } else {
                    dismiss()
                    // AuthGateView should now display LoginView.
                }
            }
        }
    }

    // MARK: - Delete Account

    private func deleteAccount() {
        guard !deletePassword.isEmpty else {
            message = "Enter your current password to delete your account."
            showMessage = true
            return
        }

        isDeleting = true

        authService.deleteAccount(password: deletePassword) { error in
            DispatchQueue.main.async {
                isDeleting = false
                deletePassword = ""

                if let error {
                    message = "Could not delete account: \(error)"
                    showMessage = true
                } else {
                    dismiss()
                    // AuthGateView should now display LoginView.
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserSettingsView()
            .environmentObject(AuthService())
    }
}
