//
//  HomeView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("AutoCare")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.primaryText)

                Text("Welcome, \(authService.user?.displayName ?? "Driver")")
                    .font(AppFonts.heading)
                    .foregroundStyle(AppColors.primaryText)

                Text(authService.user?.email ?? "")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.secondaryText)

                Text("You are signed in to Firebase.")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.accent)

                AppButton(title: "Sign Out") {
                    do {
                        try authService.signOut()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .padding(24)
        }
        .alert("Sign Out Failed", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}
