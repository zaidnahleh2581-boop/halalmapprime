import UIKit
import UserNotifications
import FirebaseMessaging

final class NotificationAppDelegate: NSObject,
                                     UIApplicationDelegate,
                                     UNUserNotificationCenterDelegate,
                                     MessagingDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        return true
    }

    // ✅ بعد permission، هذي بتشتغل وتجيب APNs token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs device token set")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ APNs register failed: \(error.localizedDescription)")
    }

    // ✅ هنا يجي FCM Token الرسمي
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken, !token.isEmpty else { return }
        print("✅ FCM token:", token)

        NotificationCenter.default.post(
            name: .didReceiveFCMToken,
            object: nil,
            userInfo: ["token": token]
        )
    }

    // ✅ لما المستخدم يضغط على الإشعار (deep link)
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
    static let didReceiveFCMToken = Notification.Name("didReceiveFCMToken")
}
