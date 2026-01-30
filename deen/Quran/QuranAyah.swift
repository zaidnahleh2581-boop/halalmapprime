//
//  QuranAyah.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/28/26.
//

import Foundation

struct QuranAyah: Decodable, Identifiable, Hashable {
    var id: Int { n }

    let n: Int
    let ar: String
    let en: String

    // injected later
    var surahId: Int? = nil

    private enum CodingKeys: String, CodingKey {
        case n, ar, en
    }
}
