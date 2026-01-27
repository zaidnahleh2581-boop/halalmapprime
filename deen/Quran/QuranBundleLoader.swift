//
//  QuranBundleLoader.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//

import Foundation

enum QuranBundleLoader {

    static func loadQuran() -> QuranRoot {
        FaithLocalStore.loadCodable(
            QuranRoot.self,
            filename: "quran_local",
            subdirectory: "deen_json"
        )
    }
}
