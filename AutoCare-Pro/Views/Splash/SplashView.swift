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
        ZStack{
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
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    size = 1.0
                    opacity = 1.0
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
