//
//  ServiceView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//
import SwiftUI

struct ServiceView: View {

    @State private var searchText: String = ""
    @State private var showLogServiceSheet: Bool = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

         
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
                    .background(AppColors.background)

 
                VStack(spacing: 20) {

                    nextServiceCard
                        .padding(.horizontal, 20)

                    lifecycleStatsCard
                        .padding(.horizontal, 20)

                    searchBarSection
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)
                .background(AppColors.background)

 
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        serviceRecordsList
                            .padding(.horizontal, 20)

                        Spacer()
                            .frame(height: 30)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showLogServiceSheet) {
            Text("Log Service Sheet")
                .presentationDetents([.medium, .large])
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Service Records")
                    .font(AppFonts.title2)
                    .foregroundStyle(AppColors.primaryText)

                Text("Maintenance records & receipts")
                    .font(AppFonts.footer)
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            Spacer()

            Button {
                showLogServiceSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.bold))

                    Text("Log Service")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundStyle(AppColors.accent)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(AppColors.buttonBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            AppColors.accent.opacity(0.3),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 5)
        }
    }

    private var nextServiceCard: some View {
        VStack(spacing: 6) {
            Text("Next Service")
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryLabel)

            Text("130,000 km • 1,358 km remaining")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var lifecycleStatsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Lifecycle Expenditure")
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryLabel)

                Text("LKR 45, 000")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Total Services")
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryLabel)

                Text("3")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)
            }
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var searchBarSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.secondaryLabel)

            TextField(
                "Search by date or service...",
                text: $searchText
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.primaryText)
        }
        .padding(14)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var serviceRecordsList: some View {
        VStack(spacing: 16) {
            serviceRecordCard(
                date: "12 Sep 2026",
                odometer: "128,642 km",
                serviceTitle: "Brake Repair and Oil and Filter Service",
                cost: "LKR 12,500",
                location: "Toyota Lanka - Walgama, Matara."
            )

            serviceRecordCard(
                date: "12 Sep 2026",
                odometer: "128,642 km",
                serviceTitle: "Brake Repair and Oil and Filter Service",
                cost: "LKR 12,500",
                location: "Toyota Lanka - Walgama, Matara."
            )

            serviceRecordCard(
                date: "12 Sep 2026",
                odometer: "128,642 km",
                serviceTitle: "Brake Repair and Oil and Filter Service",
                cost: "LKR 12,500",
                location: "Toyota Lanka - Walgama, Matara."
            )
        }
    }

    private func serviceRecordCard(
        date: String,
        odometer: String,
        serviceTitle: String,
        cost: String,
        location: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date)
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryLabel)

                Text(odometer)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Text("Verified Invoice")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
            }

            HStack(alignment: .top) {
                Text(serviceTitle)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.leading)

                Spacer()

                Text(cost)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.accent)
            }

            Text(location)
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryLabel)

            Divider()
                .overlay(AppColors.secondaryLabel.opacity(0.25))

            Button(action: {
            }) {
                HStack(spacing: 4) {
                    Spacer()

                    Text("View Service All Details")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.accent)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.accent)

                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        ServiceView()
    }
}
