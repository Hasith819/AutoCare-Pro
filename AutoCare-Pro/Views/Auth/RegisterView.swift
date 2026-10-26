//
//  RegisterView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = "Pubudu Hasith"
    @State private var email = "owner@example.com"
    @State private var password = ""
    @State private var phoneNumber = "+94 7X XXX XXXX"
    @State private var isTermsAccepted = true

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

                    VStack(spacing: 14) {
                        AppTextField(
                            title: "Full Name",
                            placeholder: "Enter your name",
                            text: $fullName
                        )

                        AppTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        AppSecureField(
                            title: "Password",
                            placeholder: "Create a password",
                            text: $password
                        )

                        AppTextField(
                            title: "Phone Number",
                            placeholder: "+94 7X XXX XXXX",
                            text: $phoneNumber,
                            keyboardType: .phonePad
                        )
                    }
                    .padding(.horizontal, 24)

                    Button(action: {
                        isTermsAccepted.toggle()
                    }) {
                        HStack(spacing: 10) {
                            Image(
                                systemName: isTermsAccepted
                                    ? "checkmark.square.fill"
                                    : "square"
                            )
                            .foregroundColor(
                                isTermsAccepted
                                    ? AppColors.primaryText
                                    : AppColors.secondaryLabel
                            )
                            .font(.system(size: 18, weight: .semibold))

                            Text("I agree to Terms & Conditions")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.primaryText)

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)

                    AppButton(title: "Create My Account") {
                        // Account creation will be added later.
                    }
                    .padding(.horizontal, 24)

                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .font(AppFonts.footer)
                            .foregroundColor(AppColors.secondaryLabel)

                        AppTextButton(title: "Sign In") {
                            dismiss()
                        }
                    }
                    .padding(.top, 4)

                    Spacer()
                        .frame(height: 30)
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
