//
//  AppTextField.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct AppTextField: View {
    let title: String
    let placeholder: String

    @Binding var text: String

    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization? = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.label)
                .foregroundColor(AppColors.secondaryLabel)

            TextField(placeholder, text: $text)
                .foregroundColor(AppColors.primaryText)
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}
