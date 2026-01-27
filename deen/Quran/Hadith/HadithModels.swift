//
//  HadithModels.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import Foundation

struct HadithRoot: Decodable {
    let items: [HadithItem]
}

struct HadithItem: Decodable, Identifiable {
    let id: String
    let text: String
    let reference: String?

    // دعم Identifiable
    var uuid: String { id }
}
