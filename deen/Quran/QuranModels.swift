//
//  QuranModels.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import Foundation

// MARK: - Root
struct QuranRoot: Decodable {
    let surahs: [QuranSurah]
}

// MARK: - Surah
struct QuranSurah: Decodable, Identifiable {
    let id: Int
    let name_ar: String
    let name_en: String
    let ayahs: [QuranAyah]
}

// MARK: - Ayah
struct QuranAyah: Decodable, Identifiable {
    let n: Int
    let ar: String
    let en: String

    var id: Int { n }
}
