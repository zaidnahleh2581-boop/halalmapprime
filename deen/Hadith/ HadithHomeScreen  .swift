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
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private let root: HadithRoot = HadithStore.load()

    var body: some View {
        List {
            if root.items.isEmpty {
                Text(L("لا يوجد أحاديث محلية. تأكد من hadith_collection.json داخل deen_json.",
                       "No local hadith. Make sure hadith_collection.json exists inside deen_json."))
                .foregroundStyle(.secondary)
            } else {
                ForEach(root.items) { h in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lang.isArabic ? h.text_ar : h.text_en)
                            .font(.body)
                            .multilineTextAlignment(lang.isArabic ? .trailing : .leading)

                        Text(lang.isArabic ? h.source_ar : h.source_en)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle(L("الأحاديث", "Hadiths"))
    }
}
