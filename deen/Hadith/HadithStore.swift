//
//  HadithStore.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import Foundation

enum HadithStore {
    
    static func load() -> HadithRoot {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        let root = FaithLocalStore.loadBundledCodableSafe(
            HadithRoot.self,
            filename: "hadith_collection",
            subdirectory: "deen_json",
            fallback: HadithRoot(items: []),
            decoder: decoder
        )
        
        print("✅ Hadith loaded count =", root.items.count)
        
        return root
    }
}
