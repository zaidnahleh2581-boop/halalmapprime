//
//  PlaceCategory.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-27.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import SwiftUI

enum PlaceCategory: String, CaseIterable, Identifiable, Codable, Hashable {

    case restaurant = "Restaurant"
    case grocery    = "Grocery"
    case school     = "School"
    case mosque     = "Mosque"
    case service    = "Service"
    case foodTruck  = "Food Truck"
    case market     = "Market"
    case shop       = "Shop"
    case center     = "Center"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .restaurant: return "Restaurants"
        case .grocery:    return "Groceries"
        case .school:     return "Schools"
        case .mosque:     return "Mosques"
        case .service:    return "Services"
        case .foodTruck:  return "Food Trucks"
        case .market:     return "Markets"
        case .shop:       return "Shops"
        case .center:     return "Centers"
        }
    }

    var googleType: String {
        switch self {
        case .restaurant: return "restaurant"
        case .grocery:    return "grocery_or_supermarket"
        case .school:     return "school"
        case .mosque:     return "mosque"
        case .service:    return "store"
        case .foodTruck:  return "meal_takeaway"
        case .market:     return "supermarket"
        case .shop:       return "store"
        case .center:     return "point_of_interest"
        }
    }

    var mapColor: Color {
        switch self {
        case .restaurant: return .red
        case .grocery:    return .green
        case .school:     return .blue
        case .mosque:     return .mint
        case .service:    return .orange
        case .foodTruck:  return .yellow
        case .market:     return .brown
        case .shop:       return .pink
        case .center:     return .teal
        }
    }

    var emoji: String {
        switch self {
        case .restaurant: return "🍽️"
        case .grocery:    return "🛒"
        case .school:     return "🏫"
        case .mosque:     return "🕌"
        case .service:    return "🛠️"
        case .foodTruck:  return "🚚"
        case .market:     return "🛍️"
        case .shop:       return "🏪"
        case .center:     return "📍"
        }
    }
}
