//
//  PlaceSubmission.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//

import Foundation
import FirebaseFirestore

struct PlaceSubmission: Identifiable, Codable, Hashable {

    @DocumentID var id: String?

    var placeName: String
    var placeType: String          // مثال: "foodtruck", "restaurant", "clinic" ...
    var addressLine: String
    var city: String
    var state: String

    var phone: String?
    var website: String?

    var foodTruckStop: String?

    var ownerId: String?
    var isFreeAd: Bool?
    var freeAdExpiresAt: Timestamp?

    var createdAt: Timestamp?
    var status: String?            // "pending" | "approved" | "rejected"

    var geo: GeoPoint?             // Firestore GeoPoint

    // Helpers
    var displayTitle: String {
        placeName.isEmpty ? "Unnamed Place" : placeName
    }

    var displayAddress: String {
        let a = addressLine.isEmpty ? "" : addressLine
        let c = city.isEmpty ? "" : city
        let s = state.isEmpty ? "" : state
        return [a, c, s].filter { !$0.isEmpty }.joined(separator: ", ")
    }
}
