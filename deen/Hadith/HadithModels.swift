//
//  HadithModels.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//
import Foundation

struct HadithRoot: Codable {
    let items: [HadithItem]
}

struct HadithItem: Codable, Identifiable {
    let id: String
    let text_ar: String
    let text_en: String
    let source_ar: String
    let source_en: String

    // ✅ optional (لو JSON فيه tags ما بصير crash)
    let tags: [String]?
}
