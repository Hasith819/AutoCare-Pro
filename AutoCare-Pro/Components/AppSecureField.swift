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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.label)
                .foregroundColor(AppColors.secondaryLabel)

            SecureField(placeholder, text: $text)
                .foregroundColor(AppColors.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}
