//
//  HadithModels.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import Foundation

// MARK: - Root
struct HadithRoot: Decodable {
    let items: [HadithItem]
}

// MARK: - Item
struct HadithItem: Decodable, Identifiable {
    let id: Int
    let text_ar: String
    let text_en: String
    let reference: String?

    var uuid: Int { id }
}
