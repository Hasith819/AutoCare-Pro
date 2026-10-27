//
//  AppSecureField.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct AppSecureField: View {

    let title: String
    let placeholder: String

    @Binding var text: String
    @State private var isPasswordVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(AppFonts.label)
                .foregroundColor(AppColors.secondaryLabel)

            HStack(spacing: 8) {
                Group {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .foregroundColor(AppColors.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(
                        systemName: isPasswordVisible
                            ? "eye.slash"
                            : "eye"
                    )
                    .foregroundColor(AppColors.secondaryLabel)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    isPasswordVisible ? "Hide password" : "Show password"
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}

