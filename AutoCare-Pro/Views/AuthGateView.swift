//
//  AuthGateView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import SwiftUI

struct AuthGateView: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        Group {
            if authService.user != nil {
                HomeView()
            } else {
                LoginView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
