//
//  MapView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var viewModel = MapViewModel()

    @Environment(\.openURL) private var openURL

    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    filterButtons
                    mapSection
                    resultsSection
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            locationService.requestPermission()
        }
        .onChange(of: locationService.currentLocation) { _, newLocation in
            guard let newLocation else { return }

            let region = MKCoordinateRegion(
                center: newLocation.coordinate,
                latitudinalMeters: 12000,
                longitudinalMeters: 12000
            )

            cameraPosition = .region(region)

            if viewModel.centers.isEmpty && !viewModel.isLoading {
                Task {
                    await viewModel.loadNearbyCenters(
                        around: newLocation
                    )
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Find Nearby Services")
                .font(AppFonts.heading)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)

            Text("Toyota workshops, repair centers and fuel stations")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.secondaryLabel)
        }
        .padding(.horizontal, 20)
    }

    private var filterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ServiceCenterType.allCases) { type in
                    Button {
                        viewModel.selectedType = type
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: type.icon)

                            Text(type.rawValue)
                                .lineLimit(1)
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .foregroundStyle(
                            viewModel.selectedType == type
                                ? AppColors.accent
                                : AppColors.secondaryLabel
                        )
                        .background(
                            viewModel.selectedType == type
                                ? AppColors.buttonBackground
                                : AppColors.inputBackground
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var mapSection: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            ForEach(viewModel.filteredCenters) { center in
                Annotation(
                    center.name,
                    coordinate: center.coordinate,
                    anchor: .bottom
                ) {
                    Image(systemName: center.type.icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppColors.accent)
                        .padding(9)
                        .background(AppColors.background)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(AppColors.accent, lineWidth: 2)
                        }
                }
            }
        }
        .mapStyle(.standard)
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(viewModel.selectedType.rawValue)
                    .font(AppFonts.heading)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                if !viewModel.filteredCenters.isEmpty {
                    Text("\(viewModel.filteredCenters.count) found")
                        .font(AppFonts.footer)
                        .foregroundStyle(AppColors.secondaryLabel)
                }
            }

            if locationService.authorizationStatus == .denied ||
                locationService.authorizationStatus == .restricted {

                Text("Enable location access for AutoCare in Settings to find nearby places.")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.secondaryLabel)

            } else if locationService.currentLocation == nil {

                ProgressView("Getting your location...")
                    .tint(AppColors.accent)
                    .foregroundStyle(AppColors.primaryText)

            } else if viewModel.isLoading {

                ProgressView("Searching nearby places...")
                    .tint(AppColors.accent)
                    .foregroundStyle(AppColors.primaryText)

            } else if let error = viewModel.errorMessage {

                Text(error)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.secondaryLabel)

                Button("Try Again") {
                    guard let location = locationService.currentLocation else {
                        return
                    }

                    Task {
                        await viewModel.loadNearbyCenters(around: location)
                    }
                }
                .foregroundStyle(AppColors.accent)

            } else if viewModel.filteredCenters.isEmpty {

                Text("No places found in this category.")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.secondaryLabel)

            } else {

                ForEach(viewModel.filteredCenters) { center in
                    serviceCenterCard(center)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func serviceCenterCard(
        _ center: ServiceCenter
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: center.type.icon)
                    .font(.title3)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 5) {
                    Text(center.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryText)
                        .multilineTextAlignment(.leading)

                    Text(center.distanceText)
                        .font(AppFonts.footer)
                        .foregroundStyle(AppColors.accent)

                    Text(center.type.rawValue)
                        .font(AppFonts.footer)
                        .foregroundStyle(AppColors.secondaryLabel)
                }

                Spacer()
            }

            Divider()
                .overlay(AppColors.secondaryLabel.opacity(0.25))

            HStack(spacing: 12) {
                if let phone = center.phoneNumber,
                   let url = phoneURL(for: phone) {

                    Button {
                        openURL(url)
                    } label: {
                        Label("Call", systemImage: "phone.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.accent)
                    }
                    .buttonStyle(.plain)

                } else {

                    Label("Phone unavailable", systemImage: "phone")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryLabel)
                }

                Spacer()

                Button {
                    openRouteInGoogleMaps(center)
                } label: {
                    Label(
                        "Route",
                        systemImage: "arrow.triangle.turn.up.right.diamond.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func phoneURL(for phone: String) -> URL? {
        let sanitizedPhone = phone.filter {
            $0.isNumber || $0 == "+"
        }

        guard !sanitizedPhone.isEmpty else {
            return nil
        }

        return URL(string: "tel:\(sanitizedPhone)")
    }

    private func openRouteInGoogleMaps(
        _ center: ServiceCenter
    ) {
        var components = URLComponents(
            string: "https://www.google.com/maps/dir/"
        )

        let destination =
            "\(center.coordinate.latitude),\(center.coordinate.longitude)"

        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: destination),
            URLQueryItem(name: "travelmode", value: "driving")
        ]

        guard let url = components?.url else { return }
        openURL(url)
    }
}

#Preview {
    NavigationStack {
        MapView()
    }
}
