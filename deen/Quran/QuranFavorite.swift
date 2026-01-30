//
//  QuranFavorite.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/27/26.
//

import Foundation

struct QuranFavorite: Identifiable, Codable, Equatable {

    let id: String
    let surahId: Int
    let ayah: Int

    let text_ar: String
    let text_en: String

    let surahNameAr: String
    let surahNameEn: String
}
