//
//  PrayerNotificationManager.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//
import UserNotifications

enum PrayerNotificationManager {

    static func schedulePrayer(
        id: String,
        title: String,
        body: String,
        date: Date
    ) {
        let defaults = UserDefaults.standard

        let notificationsEnabled =
            defaults.bool(forKey: "PrayerNotificationsEnabled")

        guard notificationsEnabled else { return }

        let adhanEnabled =
            defaults.bool(forKey: "PrayerAdhanSoundEnabled")

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if adhanEnabled {
            content.sound = UNNotificationSound(
                named: UNNotificationSoundName("adhan.mp3")
            )
        } else {
            content.sound = nil
        }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
