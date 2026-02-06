//
//  AdminJobAd.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import Foundation
import FirebaseFirestore

struct AdminJobAd: Identifiable, Hashable {
    let id: String

    let type: String
    let text: String
    let city: String
    let category: String
    let phone: String

    let createdAt: Date?
    let ownerKey: String?

    let adminHidden: Bool?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.type = data["type"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""

        if let ts = data["createdAt"] as? Timestamp { self.createdAt = ts.dateValue() }
        else { self.createdAt = nil }

        self.ownerKey = data["ownerKey"] as? String
        self.adminHidden = data["adminHidden"] as? Bool
    }
}
