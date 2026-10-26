//
//  AppButton.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//
import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.button)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.buttonBackground)
                .cornerRadius(12)
        }
    }
}

struct AppTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.footer)
                .fontWeight(.bold)
                .foregroundColor(AppColors.accent)
        }
    }
}
