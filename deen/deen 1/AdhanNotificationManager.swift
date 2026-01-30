//
//  AdhanNotificationManager.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications
import Combine   // ✅ هذا كان ناقص

@MainActor
final class AdhanNotificationManager: ObservableObject {

    static let shared = AdhanNotificationManager()

    // MARK: - Published
    @Published var permissionGranted: Bool = false
    @Published var lastScheduleMessage: String? = nil

    private init() {}

    // MARK: - Permission

    func refreshPermissionState() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        permissionGranted =
            settings.authorizationStatus == .authorized ||
            settings.authorizationStatus == .provisional
    }

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let ok = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshPermissionState()
            return ok
        } catch {
            await refreshPermissionState()
            return false
        }
    }

    // MARK: - Scheduling

    func scheduleTodayAndTomorrow(
        location: CLLocation,
        langIsArabic: Bool,
        settings: AdhanReminderSettings
    ) async {

        guard settings.isEnabled else {
            await removeAllAdhanNotifications()
            lastScheduleMessage = langIsArabic
                ? "تم إيقاف تنبيهات الأذان."
                : "Adhan reminders turned off."
            return
        }

        await refreshPermissionState()
        guard permissionGranted else {
            lastScheduleMessage = langIsArabic
                ? "يرجى السماح بالتنبيهات من الإعدادات."
                : "Please allow notifications in Settings."
            return
        }

        do {
            let today = Date()
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

            let t1 = try await fetchTimings(date: today, coordinate: location.coordinate)
            let t2 = try await fetchTimings(date: tomorrow, coordinate: location.coordinate)

            await removeAllAdhanNotifications()

            var count = 0
            count += await schedule(for: today, timings: t1, langIsArabic: langIsArabic, settings: settings)
            count += await schedule(for: tomorrow, timings: t2, langIsArabic: langIsArabic, settings: settings)

            lastScheduleMessage = langIsArabic
                ? "تمت جدولة \(count) تنبيه."
                : "Scheduled \(count) reminders."

        } catch {
            lastScheduleMessage = (langIsArabic ? "فشل الجدولة: " : "Scheduling failed: ")
                + error.localizedDescription
        }
    }

    func removeAllAdhanNotifications() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    // MARK: - Helpers

    private func schedule(
        for date: Date,
        timings: TimingsDTO,
        langIsArabic: Bool,
        settings: AdhanReminderSettings
    ) async -> Int {

        let center = UNUserNotificationCenter.current()
        let minutesBefore = settings.minutesBefore

        let items: [(Bool, String, String)] = [
            (settings.fajr,    langIsArabic ? "الفجر"   : "Fajr",    timings.fajr),
            (settings.dhuhr,   langIsArabic ? "الظهر"   : "Dhuhr",   timings.dhuhr),
            (settings.asr,     langIsArabic ? "العصر"   : "Asr",     timings.asr),
            (settings.maghrib, langIsArabic ? "المغرب"  : "Maghrib", timings.maghrib),
            (settings.isha,    langIsArabic ? "العشاء"  : "Isha",    timings.isha)
        ]

        var scheduled = 0

        for (isOn, title, hhmm) in items where isOn {
            guard let fireDate = combine(date: date, hhmm: hhmm, minusMinutes: minutesBefore),
                  fireDate > Date()
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = minutesBefore == 0
                ? (langIsArabic ? "حان وقت الصلاة" : "It's time to pray")
                : (langIsArabic ? "تبقّى \(minutesBefore) دقيقة على الصلاة"
                                : "\(minutesBefore) minutes before prayer")
            content.sound = settings.useSound ? .default : nil

            let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            let id = UUID().uuidString
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            try? await center.add(request)
            scheduled += 1
        }

        return scheduled
    }

    private func combine(date: Date, hhmm: String, minusMinutes: Int) -> Date? {
        let parts = hhmm.split(separator: ":")
        guard parts.count == 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]) else { return nil }

        var comps = Calendar.current.dateComponents([.year,.month,.day], from: date)
        comps.hour = h
        comps.minute = m

        guard let base = Calendar.current.date(from: comps) else { return nil }
        return Calendar.current.date(byAdding: .minute, value: -minusMinutes, to: base)
    }

    // MARK: - API

    private func fetchTimings(date: Date, coordinate: CLLocationCoordinate2D) async throws -> TimingsDTO {

        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        let dateStr = f.string(from: date)

        var comps = URLComponents(string: "https://api.aladhan.com/v1/timings/\(dateStr)")!
        comps.queryItems = [
            .init(name: "latitude", value: "\(coordinate.latitude)"),
            .init(name: "longitude", value: "\(coordinate.longitude)"),
            .init(name: "method", value: "2")
        ]

        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        let decoded = try JSONDecoder().decode(AlAdhanByDateResponse.self, from: data)
        let t = decoded.data.timings

        return TimingsDTO(
            fajr: clean(t.Fajr),
            dhuhr: clean(t.Dhuhr),
            asr: clean(t.Asr),
            maghrib: clean(t.Maghrib),
            isha: clean(t.Isha)
        )
    }

    private func clean(_ s: String) -> String {
        s.split(separator: " ").first.map(String.init) ?? s
    }
}

// MARK: - DTO & API Models

private struct TimingsDTO {
    let fajr: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
}

private struct AlAdhanByDateResponse: Codable {
    let data: AlAdhanByDateData
}
private struct AlAdhanByDateData: Codable {
    let timings: AlAdhanByDateTimings
}
private struct AlAdhanByDateTimings: Codable {
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
