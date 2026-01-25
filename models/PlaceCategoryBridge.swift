//
//  PlaceCategoryBridge.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/25/26.
//

import Foundation

enum PlaceCategoryBridge {
    static func toCategoryId(oldRaw: String) -> String {
        switch oldRaw {
        case "Restaurant": return "food.restaurant"
        case "Grocery": return "food.grocery"
        case "Food Truck": return "food.food_truck"
        case "Market": return "food.market"
        case "Mosque": return "community.mosque"
        case "School": return "community.school"
        case "Service": return "services.hvac"
        case "Shop": return "retail.phone_store"
        case "Center": return "community.center"
        default: return "community.center"
        }
    }
}
