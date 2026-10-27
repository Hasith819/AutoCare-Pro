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
    @StateObject private var snackBarManager = SnackBarManager()

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                SplashView()
                    .environmentObject(authService)
                    .environmentObject(snackBarManager)

                if snackBarManager.isPresented {
                    SnackBarView(
                        message: snackBarManager.message,
                        isSuccess: snackBarManager.isSuccess
                    )
                    .padding(.top, 10)
                    .transition(
                        .move(edge: .top).combined(with: .opacity)
                    )
                    .zIndex(1)
                }
            }
            .environmentObject(authService)
            .environmentObject(snackBarManager)
        }
    }
}
