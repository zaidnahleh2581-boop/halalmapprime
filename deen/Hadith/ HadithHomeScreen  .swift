//
//  HadithHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct HadithHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    // ✅ SAFE – NEVER CRASH
    private let root: HadithRoot = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        return FaithLocalStore.loadBundledCodableSafe(
            HadithRoot.self,
            filename: "hadith_local",
            subdirectory: "deen_json",
            fallback: HadithRoot(items: []),
            decoder: decoder
        )
    }()

    var body: some View {
        List {
            if root.items.isEmpty {
                Text(L("لا يوجد حديث اليوم.", "No hadith available."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(root.items) { hadith in
                    VStack(alignment: .leading, spacing: 8) {

                        Text(lang.isArabic ? hadith.text_ar : hadith.text_en)
                            .font(.body)
                            .multilineTextAlignment(
                                lang.isArabic ? .trailing : .leading
                            )
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle(L("حديث اليوم", "Hadith of the Day"))
    }
}
