//
//  AdhkarModels.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

struct AdhkarRoot: Codable {
    let categories: [AdhkarCategory]
    static let defaultValue = AdhkarRoot(categories: [])

    // ✅ JSON عندك اسمه "sections" → نحوله إلى categories
    enum CodingKeys: String, CodingKey {
        case categories = "sections"
    }
}

struct AdhkarCategory: Codable, Identifiable {
    let id: String
    let title_ar: String
    let title_en: String
    let items: [AdhkarItem]
}

struct AdhkarItem: Codable, Identifiable {
    let id: String
    let text_ar: String
    let text_en: String
    let count: Int?
}
