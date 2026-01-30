//
//  HalalMapPrimeApp.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-29.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct HalalMapPrimeApp: App {

    // ✅ Needed for notification tap → deep link inside app
    @UIApplicationDelegateAdaptor(NotificationAppDelegate.self) var notificationDelegate

    @StateObject private var languageManager = LanguageManager()
    @StateObject private var locationManager = AppLocationManager()
    @StateObject private var router = AppRouter()

    init() {
        FirebaseApp.configure()

        // ✅ Anonymous Auth (Silent) — runs once if no user session exists
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("❌ Anonymous sign-in failed:", error.localizedDescription)
                    return
                }
                print("✅ Anonymous signed in:", result?.user.uid ?? "nil")
            }
        } else {
            print("✅ Existing user:", Auth.auth().currentUser?.uid ?? "nil")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
                .environmentObject(locationManager)
                .environmentObject(router)
        }
    }
}
