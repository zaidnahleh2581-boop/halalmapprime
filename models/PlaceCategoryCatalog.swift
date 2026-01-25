//
//  PlaceCategoryCatalog.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import Foundation

struct PlaceCategoryItem: Identifiable, Hashable, Codable {
    let id: String               // categoryId (stable key)
    let groupId: String          // group key
    let titleEn: String
    let titleAr: String
    let emoji: String
    let googleType: String       // used by GooglePlacesService (optional usage)
    let requiresApproval: Bool   // Food-related etc.
    let colorName: String        // maps to SwiftUI Color via computed

    var color: Color {
        switch colorName {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "mint": return .mint
        case "orange": return .orange
        case "yellow": return .yellow
        case "brown": return .brown
        case "pink": return .pink
        case "teal": return .teal
        case "purple": return .purple
        case "indigo": return .indigo
        case "gray": return .gray
        default: return .teal
        }
    }
}

struct PlaceCategoryGroup: Identifiable, Hashable, Codable {
    let id: String
    let titleEn: String
    let titleAr: String
    let items: [PlaceCategoryItem]
}

enum PlaceCategoryCatalog {

    // ✅ كل التصنيفات هنا
    static let groups: [PlaceCategoryGroup] = [

        // -------------------------
        // FOOD (Needs approval)
        // -------------------------
        PlaceCategoryGroup(
            id: "food",
            titleEn: "Food",
            titleAr: "طعام",
            items: [
                .init(id: "food.restaurant", groupId: "food", titleEn: "Restaurant", titleAr: "مطعم", emoji: "🍽️", googleType: "restaurant", requiresApproval: true, colorName: "red"),
                .init(id: "food.grocery", groupId: "food", titleEn: "Grocery", titleAr: "بقالة", emoji: "🛒", googleType: "grocery_or_supermarket", requiresApproval: true, colorName: "green"),
                .init(id: "food.market", groupId: "food", titleEn: "Market", titleAr: "ماركت", emoji: "🛍️", googleType: "supermarket", requiresApproval: true, colorName: "brown"),
                .init(id: "food.butcher", groupId: "food", titleEn: "Butcher", titleAr: "ملحمة", emoji: "🥩", googleType: "store", requiresApproval: true, colorName: "orange"),
                .init(id: "food.food_truck", groupId: "food", titleEn: "Food Truck", titleAr: "فود ترك", emoji: "🚚", googleType: "meal_takeaway", requiresApproval: true, colorName: "yellow"),
                .init(id: "food.cafe", groupId: "food", titleEn: "Cafe", titleAr: "كافيه", emoji: "☕️", googleType: "cafe", requiresApproval: true, colorName: "pink"),
                .init(id: "food.bakery", groupId: "food", titleEn: "Bakery", titleAr: "مخبز", emoji: "🥐", googleType: "bakery", requiresApproval: true, colorName: "brown")
            ]
        ),

        // -------------------------
        // WORSHIP / COMMUNITY (Auto-approved)
        // -------------------------
        PlaceCategoryGroup(
            id: "community",
            titleEn: "Community",
            titleAr: "مجتمع",
            items: [
                .init(id: "community.mosque", groupId: "community", titleEn: "Mosque", titleAr: "مسجد", emoji: "🕌", googleType: "mosque", requiresApproval: false, colorName: "mint"),
                .init(id: "community.center", groupId: "community", titleEn: "Community Center", titleAr: "مركز", emoji: "🏛️", googleType: "point_of_interest", requiresApproval: false, colorName: "teal"),
                .init(id: "community.school", groupId: "community", titleEn: "School", titleAr: "مدرسة", emoji: "🏫", googleType: "school", requiresApproval: false, colorName: "blue")
            ]
        ),

        // -------------------------
        // HEALTH (Auto-approved)
        // -------------------------
        PlaceCategoryGroup(
            id: "health",
            titleEn: "Health",
            titleAr: "صحة",
            items: [
                .init(id: "health.clinic", groupId: "health", titleEn: "Clinic", titleAr: "عيادة", emoji: "🩺", googleType: "doctor", requiresApproval: false, colorName: "purple"),
                .init(id: "health.pharmacy", groupId: "health", titleEn: "Pharmacy", titleAr: "صيدلية", emoji: "💊", googleType: "pharmacy", requiresApproval: false, colorName: "green"),
                .init(id: "health.dentist", groupId: "health", titleEn: "Dentist", titleAr: "طبيب أسنان", emoji: "🦷", googleType: "dentist", requiresApproval: false, colorName: "blue"),
                .init(id: "health.hospital", groupId: "health", titleEn: "Hospital", titleAr: "مستشفى", emoji: "🏥", googleType: "hospital", requiresApproval: false, colorName: "red")
            ]
        ),

        // -------------------------
        // LEGAL / FINANCE (Auto-approved)
        // -------------------------
        PlaceCategoryGroup(
            id: "legal_finance",
            titleEn: "Legal & Finance",
            titleAr: "قانون ومال",
            items: [
                .init(id: "legal.law_office", groupId: "legal_finance", titleEn: "Law Office", titleAr: "مكتب محاماة", emoji: "⚖️", googleType: "lawyer", requiresApproval: false, colorName: "indigo"),
                .init(id: "finance.accounting", groupId: "legal_finance", titleEn: "Accounting", titleAr: "محاسبة", emoji: "📑", googleType: "accounting", requiresApproval: false, colorName: "gray"),
                .init(id: "finance.money_transfer", groupId: "legal_finance", titleEn: "Money Transfer", titleAr: "حوالات", emoji: "💸", googleType: "finance", requiresApproval: false, colorName: "green")
            ]
        ),

        // -------------------------
        // RETAIL (Auto-approved)
        // -------------------------
        PlaceCategoryGroup(
            id: "retail",
            titleEn: "Retail",
            titleAr: "محلات",
            items: [
                .init(id: "retail.jewelry", groupId: "retail", titleEn: "Jewelry", titleAr: "مجوهرات", emoji: "💎", googleType: "jewelry_store", requiresApproval: false, colorName: "indigo"),
                .init(id: "retail.clothing", groupId: "retail", titleEn: "Clothing", titleAr: "ملابس", emoji: "👕", googleType: "clothing_store", requiresApproval: false, colorName: "pink"),
                .init(id: "retail.barber", groupId: "retail", titleEn: "Barber", titleAr: "حلاق", emoji: "💈", googleType: "hair_care", requiresApproval: false, colorName: "red"),
                .init(id: "retail.salon", groupId: "retail", titleEn: "Salon", titleAr: "صالون", emoji: "💇‍♀️", googleType: "beauty_salon", requiresApproval: false, colorName: "purple"),
                .init(id: "retail.phone_store", groupId: "retail", titleEn: "Phone Store", titleAr: "محل موبايلات", emoji: "📱", googleType: "electronics_store", requiresApproval: false, colorName: "teal")
            ]
        ),

        // -------------------------
        // SERVICES (Auto-approved)
        // -------------------------
        PlaceCategoryGroup(
            id: "services",
            titleEn: "Services",
            titleAr: "خدمات",
            items: [
                .init(id: "services.hvac", groupId: "services", titleEn: "HVAC / Refrigeration", titleAr: "تكييف/تبريد", emoji: "🛠️", googleType: "store", requiresApproval: false, colorName: "orange"),
                .init(id: "services.auto_repair", groupId: "services", titleEn: "Auto Repair", titleAr: "ميكانيك", emoji: "🚗", googleType: "car_repair", requiresApproval: false, colorName: "gray"),
                .init(id: "services.real_estate", groupId: "services", titleEn: "Real Estate", titleAr: "عقارات", emoji: "🏠", googleType: "real_estate_agency", requiresApproval: false, colorName: "teal")
            ]
        )
    ]

    // ✅ Flat list for search/picker
    static var allItems: [PlaceCategoryItem] {
        groups.flatMap { $0.items }
    }

    static func item(for id: String) -> PlaceCategoryItem? {
        allItems.first { $0.id == id }
    }
}
