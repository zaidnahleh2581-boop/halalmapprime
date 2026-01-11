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

    // sound
    var useSound: Bool = true
    /// ضع اسم الملف داخل Bundle مثل: "adhan.caf" أو "adhan.wav"
    var soundName: String = "default"   // "default" or filename

    // calculation method (AlAdhan)
    var method: Int = 2   // 2 = MWL (default)

    static let storageKey = "adhanReminderSettings_v1" // ✅ موحد

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
