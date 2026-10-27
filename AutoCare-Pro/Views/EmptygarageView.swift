//
//  EmptygarageView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import SwiftUI

struct EmptyGarageView: View {
    // State to handle navigation or sheet presentation for adding a vehicle
    @State private var showAddVehicle = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                
                // Top Header Section
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Garage")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primaryText)

                        Text("Welcome to AutoCare")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.secondaryLabel)
                    }

                    Spacer()

                    // User Profile Icon Button
                    Button(action: {
                        // Action to open User Settings
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(AppColors.secondaryLabel)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                // Empty State Main Card
                VStack(spacing: 20) {
                    // Glowing Car Icon Circle
                    ZStack {
                        Circle()
                            .fill(AppColors.buttonBackground)
                            .frame(width: 80, height: 80)
                            .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 0)

                        Image(systemName: "car.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppColors.accent)
                    }
                    .padding(.top, 10)

                    // Empty State Text Group
                    VStack(spacing: 8) {
                        Text("No Vehicles Added Yet")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Add your first vehicle to unlock OBD telemetry, maintenance reminders, service history and reports.")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .padding(.horizontal, 20)
                .background(AppColors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                Spacer()

                // Add Your First Vehicle Button
                Button(action: {
                    showAddVehicle = true
                }) {
                    Text("+ Add Your First Vehicle")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.buttonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.accent.opacity(0.4), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        // Presents AddVehicleView sheet when the button is tapped
        .sheet(isPresented: $showAddVehicle) {
            AddVehicleView()
        }
    }
}

#Preview {
    NavigationStack {
        EmptyGarageView()
    }
}
