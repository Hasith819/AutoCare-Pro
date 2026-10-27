//
//  RegisterView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct RegisterView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    @State private var isTermsAccepted = false
    @State private var validationErrors: [String: String] = [:]
    @State private var authError = ""
    @State private var showAuthAlert = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 30)

                    Text("AutoCare")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryText)
                        .padding(.bottom, 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Account")
                            .font(AppFonts.heading)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primaryText)

                        Text("Set up your secure vehicle profile")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.secondaryLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 14) {
                        AppTextField(
                            title: "Full Name",
                            placeholder: "Enter your full name",
                            text: $fullName
                        )

                        ValidationErrorText(
                            message: validationErrors[FormValidator.fullName]
                        )

                        AppTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        ValidationErrorText(
                            message: validationErrors[FormValidator.email]
                        )

                        AppSecureField(
                            title: "Password",
                            placeholder: "Create a password",
                            text: $password
                        )

                        ValidationErrorText(
                            message: validationErrors[FormValidator.password]
                        )

                        AppTextField(
                            title: "Phone Number",
                            placeholder: "+94771234567",
                            text: $phoneNumber,
                            keyboardType: .phonePad
                        )

                        ValidationErrorText(
                            message: validationErrors[FormValidator.phoneNumber]
                        )
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            isTermsAccepted.toggle()
                        } label: {
                            HStack(spacing: 10) {
                                Image(
                                    systemName: isTermsAccepted
                                        ? "checkmark.square.fill"
                                        : "square"
                                )
                                .foregroundColor(
                                    isTermsAccepted
                                        ? AppColors.accent
                                        : AppColors.secondaryLabel
                                )
                                .font(.system(size: 18, weight: .semibold))

                                Text("I agree to Terms & Conditions")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.primaryText)

                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)

                        ValidationErrorText(
                            message: validationErrors[FormValidator.terms]
                        )
                    }
                    .padding(.horizontal, 24)

                    AppButton(
                        title: isLoading ? "Creating Account..." : "Create My Account"
                    ) {
                        register()
                    }
                    .padding(.horizontal, 24)

                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .font(AppFonts.footer)
                            .foregroundColor(AppColors.secondaryLabel)

                        AppTextButton(title: "Sign In") {
                            dismiss()
                        }
                        .disabled(isLoading)
                    }
                    .padding(.top, 4)

                    Spacer()
                        .frame(height: 30)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Registration Failed", isPresented: $showAuthAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authError)
        }
    }

    private func register() {
        guard !isLoading else { return }

        validationErrors = FormValidator.validateRegistration(
            fullName: fullName,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            termsAccepted: isTermsAccepted
        )

        guard validationErrors.isEmpty else {
            return
        }

        isLoading = true

        authService.createAccount(
            fullName: fullName,
            email: email,
            password: password,
            phoneNumber: phoneNumber
        ) { error in
            DispatchQueue.main.async {
                isLoading = false

                if let error {
                    authError = error
                    showAuthAlert = true
                } else {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthService())
    }
}
