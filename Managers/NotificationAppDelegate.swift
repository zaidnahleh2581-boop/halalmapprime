import UIKit
import UserNotifications

final class NotificationAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let info = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: .openRouteFromNotification,
            object: nil,
            userInfo: info
        )
    }
}

extension Notification.Name {
    static let openRouteFromNotification = Notification.Name("openRouteFromNotification")
}
