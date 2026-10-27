//
//  GarageView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct GarageView: View {
    // State to control user settings sheet presentation
    @State private var showUserSettings = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                    activeVehicleCard
                        .padding(.horizontal, 20)

                    statsGridSection
                        .padding(.horizontal, 20)

                    dtcAlertBanner
                        .padding(.horizontal, 20)

                    maintenanceExpensesCard
                        .padding(.horizontal, 20)

                    quickActionsSection
                        .padding(.horizontal, 20)

                    Spacer()
                        .frame(height: 30)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        // Opens User Settings as a modal sheet when profile icon is tapped
        .sheet(isPresented: $showUserSettings) {
            UserSettingsView()
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("AutoCare")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)

                Text("Your garage • protected with Face ID")
                    .font(AppFonts.footer)
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            Spacer()

            // Clickable User Profile Icon
            Button {
                showUserSettings = true
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(AppColors.secondaryLabel)
            }
            .buttonStyle(.plain)
        }
    }

    private var activeVehicleCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("ACTIVE GARAGE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.accent)

                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.accent)
                    }

                    Text("Toyota Allion • KN 2426")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Owner: Pubudu Hasith")
                        .font(.caption2)
                        .foregroundStyle(AppColors.secondaryLabel)
                }

                Spacer()

                Text("Face ID")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
            }

            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color(red: 0.12, green: 0.15, blue: 0.18))
                    .frame(height: 160)
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var statsGridSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            StatCard(
                title: "ODOMETER",
                value: "128,642 km",
                subtitle: "Next service • 132,000 km"
            )

            StatCard(
                title: "OBD STATUS",
                value: "Connected",
                subtitle: "Vehicle connection active",
                valueColor: AppColors.accent
            )

            StatCard(
                title: "REVENUE LICENSE",
                value: "87 days",
                subtitle: "Until expiration",
                valueColor: .green
            )

            StatCard(
                title: "INSURANCE",
                value: "42 days",
                subtitle: "Until expiration",
                valueColor: .green
            )
        }
    }

    private var dtcAlertBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            Text("2 DTC Fault Codes Detected")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(16)
        .background(Color.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        }
    }

    private var maintenanceExpensesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Maintenance expenses")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryLabel)

                Text("LKR 42,800")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)

                Text("Last 6 months")
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            HStack(alignment: .bottom, spacing: 16) {
                barView(height: 40)
                barView(height: 80)
                barView(height: 60)
                barView(height: 110)
                barView(height: 70)
                barView(height: 100)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func barView(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(AppColors.accent)
            .frame(width: 28, height: height)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK ACTIONS")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.secondaryLabel)

            HStack(spacing: 10) {
                quickActionButton(
                    title: "Log Service",
                    icon: "plus.square.fill",
                    bg: AppColors.buttonBackground,
                    fg: AppColors.accent
                )

                quickActionButton(
                    title: "Scan OBD",
                    icon: "magnifyingglass",
                    bg: Color.orange.opacity(0.2),
                    fg: .orange
                )

                quickActionButton(
                    title: "Export PDF",
                    icon: "doc.text.fill",
                    bg: Color.green.opacity(0.2),
                    fg: .green
                )
            }
        }
    }

    private func quickActionButton(
        title: String,
        icon: String,
        bg: Color,
        fg: Color
    ) -> some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(fg)

                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(fg)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack{
        GarageView()
    }
}
