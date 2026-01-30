import SwiftUI
import CoreLocation

struct RootView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager
    @EnvironmentObject var router: AppRouter

    @State private var pendingNotificationInfo: [AnyHashable: Any]? = nil

    var body: some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .openRouteFromNotification)) { notif in
                let info = notif.userInfo ?? [:]

                // إذا المستخدم لسه في شاشة اللغة/الموقع، نخزنها لحد ما يدخل التطبيق
                if !lang.didChooseLanguage || !isLocationAuthorized {
                    pendingNotificationInfo = info
                } else {
                    router.handleNotification(userInfo: info)
                }
            }
    }

    @ViewBuilder
    private var content: some View {

        if !lang.didChooseLanguage {
            LanguageSelectionView()

        } else if !isLocationAuthorized {
            LocationPermissionView {
                locationManager.requestWhenInUseAuthorizationIfNeeded()
            }
            .onAppear(perform: {
                locationManager.requestWhenInUseAuthorizationIfNeeded()
            })

        } else {
            MainTabView()
                .onAppear(perform: {
                    locationManager.requestSingleLocationIfPossible()

                    if let info = pendingNotificationInfo {
                        pendingNotificationInfo = nil
                        router.handleNotification(userInfo: info)
                    }
                })
        }
    }

    private var isLocationAuthorized: Bool {
        let s = locationManager.authorizationStatus
        return s == .authorizedWhenInUse || s == .authorizedAlways
    }
}
