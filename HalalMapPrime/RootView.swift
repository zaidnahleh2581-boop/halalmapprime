import SwiftUI
import CoreLocation

struct RootView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {

        // 1️⃣ Language first
        if !lang.didChooseLanguage {
            LanguageSelectionView()

        // 2️⃣ Location permission
        } else if !isLocationAuthorized {
            LocationPermissionView {
                // onContinue
            }

        // 3️⃣ Main app
        } else {
            MainTabView()
        }
    }

    private var isLocationAuthorized: Bool {
        let s = locationManager.authorizationStatus
        return s == .authorizedWhenInUse || s == .authorizedAlways
    }
}
