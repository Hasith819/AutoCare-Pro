//
//  SplashView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct SplashView: View {

    @State private var size: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var progress: CGFloat = 0.0
    @State private var showLogin = false

    var body: some View {
        Group {
            if showLogin {
                LoginView()
            } else {
                splashScreen
            }
        }
    }

    private var splashScreen: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("AutoCare")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)

                Text("Vehicle Telemetry & Diagnostics")
                    .font(AppFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.secondaryText)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))

                        Capsule()
                            .fill(Color.green)
                            .frame(
                                width: geometry.size.width * progress
                            )
                    }
                }
                .frame(width: 190, height: 4)
                .padding(.top, 18)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    size = 1.0
                    opacity = 1.0
                }

                withAnimation(.easeInOut(duration: 2.0)) {
                    progress = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showLogin = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
