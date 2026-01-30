//
//  AdhanReminderSettings.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

struct AdhanReminderSettings: Codable {

    // master
    var isEnabled: Bool = false

    // which prayers
    var fajr: Bool = true
    var dhuhr: Bool = true
    var asr: Bool = true
    var maghrib: Bool = true
    var isha: Bool = true

    // reminder minutes before prayer (0 = at time)
    var minutesBefore: Int = 0

    // sound setting (simple flag; actual sound is system default unless you add custom sound file later)
    var useSound: Bool = true

    static let storageKey = "adhan_reminder_settings_v1"

    static func load() -> AdhanReminderSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(AdhanReminderSettings.self, from: data)
        else {
            return AdhanReminderSettings()
        }
        return decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
