//
//  HadithHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import SwiftUI

struct HadithHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager

    // تحميل الأحاديث من JSON المحلي
    private let root: HadithRoot = FaithLocalStore.loadCodable(
        HadithRoot.self,
        filename: "hadith_local",
        subdirectory: "deen_json"
    )

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

                            Text(h.text)
                                .font(.body)

                            if let ref = h.reference, !ref.isEmpty {
                                Text(ref)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text(lang.isArabic ? "حديث اليوم" : "Hadith of the Day")
                    }
                } else {
                    Text(lang.isArabic ? "لا يوجد حديث" : "No hadith available")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(lang.isArabic ? "الأحاديث" : "Hadith")
        }
    }
}
