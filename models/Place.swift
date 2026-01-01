//
//  Place.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import CoreLocation

struct Place: Identifiable, Hashable {

    // MARK: - Core
    let id: String
    let name: String
    let address: String
    let cityState: String
    let latitude: Double
    let longitude: Double
    let category: PlaceCategory

    // MARK: - Meta
    let rating: Double
    let reviewCount: Int
    let deliveryAvailable: Bool
    let isCertified: Bool

    // MARK: - Contact
    let phone: String?
    let website: String?

    // MARK: - Ads
    let adStatus: String        // free | paid
    let adPlan: String          // weekly | monthly | prime
    let adPriority: Int
    let startAt: Date?
    let endAt: Date?
    let isAdActive: Bool

    // MARK: - Computed
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    var formattedAddress: String {
        "\(address), \(cityState)"
    }

    var resolvedPriority: Int {
        adPriority
    }
}
