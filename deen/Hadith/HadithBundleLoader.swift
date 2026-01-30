//
//  HadithBundleLoader.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/30/26.
//

import Foundation

enum HadithBundleLoader {
    static func loadAll() -> HadithRoot? {
        guard let url = Bundle.main.url(forResource: "hadith_collection", withExtension: "json") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(HadithRoot.self, from: data)
        } catch {
            print("❌ Hadith JSON decode error:", error)
            return nil
        }
    }
}
