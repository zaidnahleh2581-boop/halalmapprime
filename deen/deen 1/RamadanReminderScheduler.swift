//
//  RamadanReminderScheduler.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/30/26.
//

import Foundation
import UserNotifications

enum RamadanReminderScheduler {

    static func requestPermissionIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    static func scheduleForToday(
        imsak: Date,
        maghrib: Date,
        minutesBefore: Int,
        isArabic: Bool
    ) {
        let center = UNUserNotificationCenter.current()

        // remove only ramadan reminders
        center.getPendingNotificationRequests { reqs in
            let ids = reqs.map(\.identifier).filter { $0.hasPrefix("ramadan_") }
            center.removePendingNotificationRequests(withIdentifiers: ids)

            scheduleOne(center: center,
                        id: "ramadan_iftar",
                        fireDate: maghrib.addingTimeInterval(TimeInterval(-minutesBefore * 60)),
                        title: isArabic ? "اقترب الإفطار" : "Iftar Soon",
                        body: isArabic ? "باقي \(minutesBefore) دقائق على أذان المغرب" : "\(minutesBefore) minutes until Maghrib",
                        userInfo: ["route": "imsakiyah"])

            scheduleOne(center: center,
                        id: "ramadan_imsak",
                        fireDate: imsak.addingTimeInterval(TimeInterval(-minutesBefore * 60)),
                        title: isArabic ? "اقترب الإمساك" : "Imsak Soon",
                        body: isArabic ? "باقي \(minutesBefore) دقائق على الإمساك" : "\(minutesBefore) minutes until Imsak",
                        userInfo: ["route": "imsakiyah"])
        }
    }

    private static func scheduleOne(
        center: UNUserNotificationCenter,
        id: String,
        fireDate: Date,
        title: String,
        body: String,
        userInfo: [String: Any]
    ) {
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
