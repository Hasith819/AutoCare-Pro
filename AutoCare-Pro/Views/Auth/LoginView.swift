//
//  LoginView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""

    @State private var validationErrors: [String: String] = [:]
    @State private var showValidationAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    Text("AutoCare")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryText)
                        .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome back")
                            .font(AppFonts.heading)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primaryText)

                        Text("Secure access to your vehicle garage")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.secondaryLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 14) {
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
                            placeholder: "Enter your password",
                            text: $password
                        )

                        ValidationErrorText(
                            message: validationErrors[FormValidator.password]
                        )
                    }
                    .padding(.horizontal, 24)

                    AppButton(title: "Sign In") {
                        login()
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 4) {
                        Text("New here?")
                            .font(AppFonts.footer)
                            .foregroundColor(AppColors.secondaryLabel)

                        NavigationLink {
                            RegisterView()
                        } label: {
                            Text("Create Account")
                                .font(AppFonts.footer)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.accent)
                        }
                    }
                    .padding(.top, 8)

                    Spacer()
                }
            }
            .preferredColorScheme(.dark)
            .alert("Validation Successful", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your fields are valid. Actual sign-in still needs to be connected to an authentication service.")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func login() {
        validationErrors = FormValidator.validateLogin(
            email: email,
            password: password
        )

        guard validationErrors.isEmpty else {
            showValidationAlert = false
            return
        }

        showValidationAlert = true
    }
}

#Preview {
    LoginView()
}
