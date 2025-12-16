//
//  Ad.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/16/25.
//

import Foundation

struct Ad: Identifiable, Hashable, Codable {

    enum Tier: String, Codable {
        case free, standard, prime

        var priority: Int {
            switch self {
            case .free: return 0
            case .standard: return 1
            case .prime: return 2
            }
        }
    }

    enum Status: String, Codable {
        case pending, active, paused, expired
    }

    let id: String
    let placeId: String
    let imagePaths: [String]   // local filenames الآن
    let tier: Tier
    let status: Status
    let createdAt: Date

    // ✅ مدة الإعلان الافتراضية
    var durationDays: Int {
        switch tier {
        case .free: return 30
        case .standard: return 30   // لاحقاً نغيرها حسب الخطة
        case .prime: return 30      // لاحقاً نغيرها حسب الخطة
        }
    }

    // ✅ تاريخ الانتهاء
    var expiresAt: Date {
        Calendar.current.date(byAdding: .day, value: durationDays, to: createdAt) ?? createdAt
    }

    // ✅ هل انتهى؟
    var isExpired: Bool {
        Date() >= expiresAt
    }

    init(
        id: String = UUID().uuidString,
        placeId: String,
        imagePaths: [String],
        tier: Tier,
        status: Status = .active,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.placeId = placeId
        self.imagePaths = Array(imagePaths.prefix(3))
        self.tier = tier
        self.status = status
        self.createdAt = createdAt
    }
}
