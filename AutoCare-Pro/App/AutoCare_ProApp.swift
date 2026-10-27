//
//  AutoCare_ProApp.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI
import FirebaseCore

class FirebaseAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


@main
struct AutoCareProApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self)
    var appDelegate

    @StateObject private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authService)
        }
    }
}
