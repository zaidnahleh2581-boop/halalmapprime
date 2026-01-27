//
//  HadithHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import SwiftUI

struct HadithHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager

    // ✅ تحميل آمن بدون crash
    private let root: HadithRoot

    init() {
        if let loaded = FaithLocalStore.loadCodableSafe(
            HadithRoot.self,
            filename: "hadith_local",
            subdirectory: "deen_json"
        ) {
            self.root = loaded
        } else {
            // fallback آمن
            self.root = HadithRoot(items: [])
            print("❌ Hadith JSON failed to load")
        }
    }

    private var hadithOfDay: HadithItem? {
        guard !root.items.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return root.items[day % root.items.count]
    }

    var body: some View {
        NavigationStack {
            List {
                if let h = hadithOfDay {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(lang.isArabic ? h.text_ar : h.text_en)
                                .font(.body)

                            if let ref = h.reference {
                                Text(ref)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    Text(lang.isArabic ? "لا يوجد أحاديث." : "No hadith available.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(lang.isArabic ? "حديث اليوم" : "Hadith of the Day")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
