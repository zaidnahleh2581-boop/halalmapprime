//
//  QuranSurah.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/28/26.
//

import Foundation

struct QuranSurah: Decodable, Identifiable {
    let id: Int
    let name_ar: String
    let name_en: String
    let ayahs: [QuranAyah]
}
