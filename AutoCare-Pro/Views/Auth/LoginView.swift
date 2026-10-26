//
//  LoginView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct LoginView: View {
    @State private var email = "owner@example.com"
    @State private var password = "••••••••••"
    
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
                
                
                VStack(spacing: 16) {
                    
                    AppTextField(
                        title: "Email",
                        placeholder: "",
                        text: $email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    
                    AppSecureField(
                        title: "Password",
                        placeholder: "",
                        text: $password
                    )
                }
                .padding(.horizontal, 24)
                
                AppButton(title: "Sign In") {
                    // Login functionality will be added later.
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
    }
        .toolbar(.hidden, for: .navigationBar)
    
  }
}

#Preview {
    LoginView()
}
