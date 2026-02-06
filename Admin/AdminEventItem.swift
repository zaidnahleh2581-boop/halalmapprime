//
//  AdminEventItem.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import Foundation
import FirebaseFirestore

enum AdminEventSource: String {
    case eventAds
    case cityEventAds
}

struct AdminEventItem: Identifiable, Hashable {
    let id: String
    let source: AdminEventSource

    let title: String
    let city: String
    let category: String
    let createdAt: Date?

    let ownerKey: String?
    let adminHidden: Bool?

    init(id: String, source: AdminEventSource, data: [String: Any]) {
        self.id = id
        self.source = source

        self.title = data["title"] as? String ?? data["name"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.category = data["category"] as? String ?? ""

        if let ts = data["createdAt"] as? Timestamp { self.createdAt = ts.dateValue() }
        else { self.createdAt = nil }

        self.ownerKey = data["ownerKey"] as? String
        self.adminHidden = data["adminHidden"] as? Bool
    }
}
