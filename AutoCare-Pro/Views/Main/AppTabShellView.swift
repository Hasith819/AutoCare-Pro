//
//  AppTabShellView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct AppTabShellView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GarageView()
            }
            .tabItem {
                Label("Garage", systemImage: "car.fill")
            }

            NavigationStack {
                TelemetryView()
            }
            .tabItem {
                Label("Telemetry", systemImage: "gauge")
            }

            NavigationStack {
                ServiceView()
            }
            .tabItem {
                Label("Service", systemImage: "wrench.and.screwdriver.fill")
            }

            NavigationStack {
                MapView()
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }

            NavigationStack {
                ReportView()
            }
            .tabItem {
                Label("Report", systemImage: "doc.text.fill")
            }
        }
        .tint(AppColors.accent)
    }
}

#Preview {
    AppTabShellView()
        .environmentObject(AuthService())
        .environmentObject(SnackBarManager())
}
