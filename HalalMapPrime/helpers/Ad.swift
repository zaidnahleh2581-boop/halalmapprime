//
//  Ad.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
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

    enum BusinessType: String, Codable, CaseIterable, Identifiable {
        case restaurant
        case grocery
        case butcher
        case deli
        case bakery
        case cafe
        case foodTruck
        case market
        case other

        var id: String { rawValue }

        var titleEN: String {
            switch self {
            case .restaurant: return "Restaurant"
            case .grocery: return "Grocery"
            case .butcher: return "Butcher"
            case .deli: return "Deli"
            case .bakery: return "Bakery"
            case .cafe: return "Cafe"
            case .foodTruck: return "Food Truck"
            case .market: return "Market"
            case .other: return "Other"
            }
        }

        var titleAR: String {
            switch self {
            case .restaurant: return "مطعم"
            case .grocery: return "بقالة"
            case .butcher: return "ملحمة"
            case .deli: return "ديلي"
            case .bakery: return "مخبز"
            case .cafe: return "كافيه"
            case .foodTruck: return "فود ترك"
            case .market: return "سوق"
            case .other: return "أخرى"
            }
        }
    }

    enum CopyTemplate: String, Codable, CaseIterable, Identifiable {
        case simple
        case halalVerifiedStyle
        case familyFriendly
        case newOpening

        var id: String { rawValue }

        var titleEN: String {
            switch self {
            case .simple: return "Simple"
            case .halalVerifiedStyle: return "Halal-focused"
            case .familyFriendly: return "Family friendly"
            case .newOpening: return "New opening"
            }
        }

        var titleAR: String {
            switch self {
            case .simple: return "بسيط"
            case .halalVerifiedStyle: return "حلال (تركيز)"
            case .familyFriendly: return "مناسب للعائلة"
            case .newOpening: return "افتتاح جديد"
            }
        }
    }

    // MARK: - Core
    let id: String
    let tier: Tier
    var status: Status

    // MARK: - Linking (optional for v1)
    var placeId: String?        // لو موجود يفتح PlaceDetail

    // MARK: - Media
    let imagePaths: [String]    // local filenames (Documents)

    // MARK: - Business info (required for Free Ads)
    let businessName: String
    let ownerName: String
    let phone: String
    let addressLine: String
    let city: String
    let state: String
    let businessType: BusinessType

    // MARK: - Copy (auto-generated)
    let template: CopyTemplate

    // MARK: - Duration / Cooldown
    let createdAt: Date
    let expiresAt: Date         // 14 days
    let freeCooldownKey: String // نستخدمه لمنع Free Ad أكثر من مرة بالشهر (مثل phone)

    init(
        id: String = UUID().uuidString,
        tier: Tier,
        status: Status = .active,
        placeId: String? = nil,
        imagePaths: [String],
        businessName: String,
        ownerName: String,
        phone: String,
        addressLine: String,
        city: String,
        state: String,
        businessType: BusinessType,
        template: CopyTemplate,
        createdAt: Date = Date(),
        expiresAt: Date,
        freeCooldownKey: String
    ) {
        self.id = id
        self.tier = tier
        self.status = status
        self.placeId = placeId
        self.imagePaths = Array(imagePaths.prefix(3))

        self.businessName = businessName
        self.ownerName = ownerName
        self.phone = phone
        self.addressLine = addressLine
        self.city = city
        self.state = state
        self.businessType = businessType
        self.template = template

        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.freeCooldownKey = freeCooldownKey
    }

    // MARK: - Computed
    var isExpired: Bool { Date() >= expiresAt }

    func generatedCopy(isArabic: Bool) -> String {
        let type = isArabic ? businessType.titleAR : businessType.titleEN
        let location = "\(city), \(state)".trimmingCharacters(in: .whitespacesAndNewlines)

        switch template {
        case .simple:
            return isArabic
            ? "زوروا \(businessName) (\(type)) في \(location). للتواصل: \(phone)."
            : "Visit \(businessName) (\(type)) in \(location). Contact: \(phone)."

        case .halalVerifiedStyle:
            return isArabic
            ? "\(businessName) — \(type) حلال لخدمة المجتمع. العنوان: \(addressLine), \(location). هاتف: \(phone)."
            : "\(businessName) — a halal-focused \(type) serving the community. Address: \(addressLine), \(location). Phone: \(phone)."

        case .familyFriendly:
            return isArabic
            ? "\(businessName) (\(type)) مناسب للعائلات. موقعنا: \(addressLine), \(location). اتصل: \(phone)."
            : "\(businessName) (\(type)) family-friendly. We’re at \(addressLine), \(location). Call: \(phone)."

        case .newOpening:
            return isArabic
            ? "افتتاح/تجديد \(businessName)! \(type) في \(location). زورونا: \(addressLine)."
            : "New (re)opening: \(businessName)! \(type) in \(location). Visit us at \(addressLine)."
        }
    }
}
import FirebaseFirestore

extension Ad {

    func toFirestore() -> [String: Any] {
        return [
            "tier": tier.rawValue,
            "status": status.rawValue,
            "placeId": placeId as Any,
            "imagePaths": imagePaths,

            "businessName": businessName,
            "ownerName": ownerName,
            "phone": phone,
            "addressLine": addressLine,
            "city": city,
            "state": state,
            "businessType": businessType.rawValue,

            "template": template.rawValue,

            "createdAt": Timestamp(date: createdAt),
            "expiresAt": Timestamp(date: expiresAt),
            "freeCooldownKey": freeCooldownKey
        ]
    }

    static func fromFirestore(id: String, data: [String: Any]) -> Ad? {
        guard
            let tierStr = data["tier"] as? String,
            let tier = Tier(rawValue: tierStr),
            let statusStr = data["status"] as? String,
            let status = Status(rawValue: statusStr),

            let imagePaths = data["imagePaths"] as? [String],

            let businessName = data["businessName"] as? String,
            let ownerName = data["ownerName"] as? String,
            let phone = data["phone"] as? String,
            let addressLine = data["addressLine"] as? String,
            let city = data["city"] as? String,
            let state = data["state"] as? String,

            let businessTypeStr = data["businessType"] as? String,
            let businessType = BusinessType(rawValue: businessTypeStr),

            let templateStr = data["template"] as? String,
            let template = CopyTemplate(rawValue: templateStr),

            let createdAtTS = data["createdAt"] as? Timestamp,
            let expiresAtTS = data["expiresAt"] as? Timestamp,

            let freeCooldownKey = data["freeCooldownKey"] as? String
        else {
            return nil
        }

        let placeId = data["placeId"] as? String

        return Ad(
            id: id,
            tier: tier,
            status: status,
            placeId: placeId,
            imagePaths: imagePaths,
            businessName: businessName,
            ownerName: ownerName,
            phone: phone,
            addressLine: addressLine,
            city: city,
            state: state,
            businessType: businessType,
            template: template,
            createdAt: createdAtTS.dateValue(),
            expiresAt: expiresAtTS.dateValue(),
            freeCooldownKey: freeCooldownKey
        )
    }
}
