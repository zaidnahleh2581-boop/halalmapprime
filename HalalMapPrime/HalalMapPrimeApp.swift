import SwiftUI
import FirebaseCore

@main
struct HalalMapPrimeApp: App {

    @StateObject private var languageManager = LanguageManager()
    @StateObject private var locationManager = AppLocationManager()
    @StateObject private var appRouter = AppRouter()   // ✅ NEW

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
                .environmentObject(locationManager)
                .environmentObject(appRouter)          // ✅ IMPORTANT
        }
    }
}
