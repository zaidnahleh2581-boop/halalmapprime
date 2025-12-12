//
//  Place.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh
//  Owner: Zaid Nahleh
//  Project: Halal Map Prime
//  Copyright © 2025 Halal Map Prime.
//  All rights reserved.
//
//  Badge system defined by Zaid Nahleh:
//  - Halal Food (GREEN) -> only for food sellers AFTER verification
//  - Islamic Place (ORANGE) -> mosques & schools (direct)
//  - Community Place (BLUE/GRAY) -> all other places (direct)
//

import Foundation
import CoreLocation

struct Place: Identifiable, Hashable {

    // MARK: - Core Properties
    let id: String
    let name: String
    let address: String
    let cityState: String
    let latitude: Double
    let longitude: Double
    let category: PlaceCategory
    let rating: Double
    let reviewCount: Int
    let deliveryAvailable: Bool

    /// Halal verification status (default: false)
    let isCertified: Bool

    /// Optional verification metadata
    let verifiedAt: Date?
    let verifiedSource: String?   // Example: "WhatsApp"

    // MARK: - Initializer (Backward compatible)
    init(
        id: String,
        name: String,
        address: String,
        cityState: String,
        latitude: Double,
        longitude: Double,
        category: PlaceCategory,
        rating: Double,
        reviewCount: Int,
        deliveryAvailable: Bool,
        isCertified: Bool = false,
        verifiedAt: Date? = nil,
        verifiedSource: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.cityState = cityState
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.rating = rating
        self.reviewCount = reviewCount
        self.deliveryAvailable = deliveryAvailable
        self.isCertified = isCertified
        self.verifiedAt = verifiedAt
        self.verifiedSource = verifiedSource
    }

    // MARK: - Helpers
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Food sellers require verification to get the GREEN badge
    var isFoodSeller: Bool {
        switch category {
        case .restaurant, .foodTruck, .grocery:
            return true
        default:
            return false
        }
    }

    /// Mosques & schools get ORANGE badge directly
    var isIslamicPlace: Bool {
        switch category {
        case .mosque, .school:
            return true
        default:
            return false
        }
    }

    /// Badge type returned by the policy
    enum BadgeType: String, Codable {
        case halalFood       // 🟢
        case islamicPlace    // 🟠
        case communityPlace  // 🔵/gray
    }

    /// Returns the badge type based on your policy.
    /// - Food sellers: badge only if verified
    /// - Mosques/Schools: always islamicPlace
    /// - Others: always communityPlace
    var badgeType: BadgeType? {
        if isIslamicPlace {
            return .islamicPlace
        }

        if isFoodSeller {
            return isCertified ? .halalFood : nil
        }

        return .communityPlace
    }
}
