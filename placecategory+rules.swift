//
//  PlaceCategory+Rules.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/12/25.
//

import Foundation
import SwiftUI

extension PlaceCategory {

    /// فقط أنواع "الأكل" تحتاج توثيق (Verified) — والباقي عادي.
    var requiresVerification: Bool {
        switch self {
        case .restaurant, .foodTruck, .grocery, .market:
            return true
        default:
            return false
        }
    }

    /// لون الشارة حسب نوع المكان
    var badgeColor: Color {
        if requiresVerification { return .green }   // Food
        return .orange                              // Community
    }

    /// نص الشارة
    func badgeTitle(isCertified: Bool) -> String {
        if requiresVerification {
            return isCertified ? "Halal Verified" : "Unverified"
        } else {
            return "Community"
        }
    }

    /// أيقونة الشارة
    func badgeIcon(isCertified: Bool) -> String {
        if requiresVerification {
            return isCertified ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
        } else {
            return "building.2.fill"
        }
    }
}
