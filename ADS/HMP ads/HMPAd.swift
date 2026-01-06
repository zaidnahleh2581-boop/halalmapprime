//
//  HMPAd.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-05.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import UIKit

struct HMPAd: Identifiable, Codable, Equatable {

    let id: String
    let ownerKey: String

    let plan: HMPAdPlanKind
    let isFeatured: Bool
    let audience: String

    let businessName: String
    let headline: String
    let adText: String

    let phone: String
    let website: String
    let addressHint: String

    // ✅ NEW: store images locally as Base64
    let imageBase64s: [String]

    let createdAt: Date
    let expiresAt: Date

    var isActive: Bool { Date() < expiresAt }

    func remainingText(langIsArabic: Bool) -> String {
        let now = Date()
        if now >= expiresAt { return langIsArabic ? "منتهي" : "Expired" }

        let diff = Calendar.current.dateComponents([.day, .hour], from: now, to: expiresAt)
        let d = max(0, diff.day ?? 0)
        let h = max(0, diff.hour ?? 0)

        if d > 0 { return langIsArabic ? "متبقي \(d) يوم" : "\(d)d left" }
        return langIsArabic ? "متبقي \(h) ساعة" : "\(h)h left"
    }

    func uiImages() -> [UIImage] {
        imageBase64s.compactMap { str in
            guard let data = Data(base64Encoded: str) else { return nil }
            return UIImage(data: data)
        }
    }
}
