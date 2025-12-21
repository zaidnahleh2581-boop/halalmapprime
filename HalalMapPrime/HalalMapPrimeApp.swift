//
//  HalalMapPrimeApp.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/17/25
//

import SwiftUI
import FirebaseCore
import GoogleMaps

@main
struct HalalMapPrimeApp: App {

    @StateObject private var languageManager = LanguageManager()

    init() {
        FirebaseApp.configure()

        guard let apiKey = Bundle.main.infoDictionary?["GOOGLE_MAPS_API_KEY"] as? String,
              !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("❌ GOOGLE_MAPS_API_KEY not found in Info.plist")
        }

        GMSServices.provideAPIKey(apiKey)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
        }
    }
}
