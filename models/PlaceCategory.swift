//
//  PlaceCategory.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/12/25.
//

import Foundation
import SwiftUI

enum PlaceCategory: String, CaseIterable, Identifiable, Codable {
    case restaurant = "Restaurant"
    case grocery    = "Grocery"
    case school     = "School"
    case mosque     = "Mosque"
    case service    = "Service"
    case foodTruck  = "Food Truck"
    case market     = "Market"
    case shop       = "Shop"
    case center     = "Center"
    case funeral    = "Funeral"

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
        case .funeral:    return "Funeral"
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
        case .funeral:    return "funeral_home"
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
        case .funeral:    return .black
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
        case .funeral:    return "⚰️"
        }
    }
}
