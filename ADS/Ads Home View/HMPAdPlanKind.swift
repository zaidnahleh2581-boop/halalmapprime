//
//  HMPAdPlanKind.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-05.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

enum HMPAdPlanKind: String, Identifiable, CaseIterable, Codable {

    case freeOnce
    case weekly
    case monthly
    case prime

    var id: String { rawValue }

    // MARK: - Titles
    var titleEN: String {
        switch self {
        case .freeOnce: return "Free Ad (One Time)"
        case .weekly:   return "Weekly Ad"
        case .monthly:  return "Monthly Ad"
        case .prime:    return "Prime Ad"
        }
    }

    var titleAR: String {
        switch self {
        case .freeOnce: return "إعلان مجاني (مرة واحدة)"
        case .weekly:   return "إعلان أسبوعي"
        case .monthly:  return "إعلان شهري"
        case .prime:    return "إعلان مميز"
        }
    }

    // MARK: - Duration
    var durationDays: Int {
        switch self {
        case .freeOnce: return 30
        case .weekly:   return 7
        case .monthly:  return 30
        case .prime:    return 30
        }
    }

    var durationTextEN: String {
        switch self {
        case .freeOnce: return "30 days (one-time)"
        case .weekly:   return "7 days"
        case .monthly:  return "30 days"
        case .prime:    return "30 days"
        }
    }

    var durationTextAR: String {
        switch self {
        case .freeOnce: return "30 يوم (مرة واحدة)"
        case .weekly:   return "7 أيام"
        case .monthly:  return "30 يوم"
        case .prime:    return "30 يوم"
        }
    }

    // MARK: - Placement
    var placementTextEN: String {
        switch self {
        case .freeOnce:
            return "Appears on Home like a normal ad (30 days)"
        case .weekly:
            return "Short campaign • 7 days"
        case .monthly:
            return "Standard campaign • 30 days"
        case .prime:
            return "Top placement • Featured slider on Home (30 days)"
        }
    }

    var placementTextAR: String {
        switch self {
        case .freeOnce:
            return "يظهر في الرئيسية كإعلان عادي (30 يوم)"
        case .weekly:
            return "حملة قصيرة • 7 أيام"
        case .monthly:
            return "حملة قياسية • 30 يوم"
        case .prime:
            return "أعلى ظهور • سلايدر الإعلانات المميزة في الرئيسية (30 يوم)"
        }
    }

    // MARK: - Featured
    var isFeatured: Bool {
        switch self {
        case .freeOnce: return false
        case .weekly:   return false
        case .monthly:  return false
        case .prime:    return true
        }
    }

    var tint: Color {
        switch self {
        case .freeOnce: return .green
        case .weekly:   return .cyan
        case .monthly:  return .blue
        case .prime:    return .orange
        }
    }
}
