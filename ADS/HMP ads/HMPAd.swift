//
//  HMPAd.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-09.
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

    // ✅ Legacy (old ads): base64 images stored in Firestore
    let imageBase64s: [String]

    // ✅ New (storage): URLs stored in Firestore
    let imageURLs: [String]

    let createdAt: Date
    let expiresAt: Date

    var isActive: Bool { Date() < expiresAt }

    // MARK: - Helpers

    func remainingText(langIsArabic: Bool) -> String {
        let now = Date()
        if now >= expiresAt { return langIsArabic ? "منتهي" : "Expired" }

        let diff = Calendar.current.dateComponents([.day, .hour], from: now, to: expiresAt)
        let d = max(0, diff.day ?? 0)
        let h = max(0, diff.hour ?? 0)

        if d > 0 { return langIsArabic ? "متبقي \(d) يوم" : "\(d)d left" }
        return langIsArabic ? "متبقي \(h) ساعة" : "\(h)h left"
    }

    /// ✅ For legacy base64 only (fast local decode).
    /// For imageURLs you should load them async in UI (AsyncImage / your loader).
    func uiImages() -> [UIImage] {
        imageBase64s.compactMap { str in
            guard let data = Data(base64Encoded: str) else { return nil }
            return UIImage(data: data)
        }
    }

    // MARK: - Codable (safe / flexible)

    enum CodingKeys: String, CodingKey {
        case id, ownerKey
        case plan, isFeatured, audience
        case businessName, headline, adText
        case phone, website, addressHint
        case imageBase64s, imageURLs
        case createdAt, expiresAt
    }

    init(
        id: String,
        ownerKey: String,
        plan: HMPAdPlanKind,
        isFeatured: Bool,
        audience: String,
        businessName: String,
        headline: String,
        adText: String,
        phone: String,
        website: String,
        addressHint: String,
        imageBase64s: [String] = [],
        imageURLs: [String] = [],
        createdAt: Date,
        expiresAt: Date
    ) {
        self.id = id
        self.ownerKey = ownerKey
        self.plan = plan
        self.isFeatured = isFeatured
        self.audience = audience
        self.businessName = businessName
        self.headline = headline
        self.adText = adText
        self.phone = phone
        self.website = website
        self.addressHint = addressHint
        self.imageBase64s = imageBase64s
        self.imageURLs = imageURLs
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try c.decode(String.self, forKey: .id)
        self.ownerKey = try c.decode(String.self, forKey: .ownerKey)

        self.plan = try c.decode(HMPAdPlanKind.self, forKey: .plan)
        self.isFeatured = try c.decode(Bool.self, forKey: .isFeatured)
        self.audience = try c.decode(String.self, forKey: .audience)

        self.businessName = try c.decode(String.self, forKey: .businessName)
        self.headline = try c.decode(String.self, forKey: .headline)
        self.adText = try c.decode(String.self, forKey: .adText)

        self.phone = (try? c.decode(String.self, forKey: .phone)) ?? ""
        self.website = (try? c.decode(String.self, forKey: .website)) ?? ""
        self.addressHint = (try? c.decode(String.self, forKey: .addressHint)) ?? ""

        // ✅ tolerate missing fields (old docs)
        self.imageBase64s = (try? c.decode([String].self, forKey: .imageBase64s)) ?? []
        self.imageURLs = (try? c.decode([String].self, forKey: .imageURLs)) ?? []

        self.createdAt = try c.decode(Date.self, forKey: .createdAt)
        self.expiresAt = try c.decode(Date.self, forKey: .expiresAt)
    }
}
