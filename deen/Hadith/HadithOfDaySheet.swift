//
//  HadithOfDaySheet.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/30/26.
//

import SwiftUI

struct HadithOfDaySheet: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    let forcedHadithId: String?

    var body: some View {
        NavigationStack {

            let all = HadithStore.load().items

            let picked = HadithOfDaySelector.pickTwo(for: Date(), from: all)
            let morning = picked?.morning
            let evening = picked?.evening

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    if let forcedHadithId,
                       let h = all.first(where: { $0.id == forcedHadithId }) {
                        HadithCard(
                            title: L("الحديث", "Hadith"),
                            text: lang.isArabic ? h.text_ar : h.text_en,
                            source: lang.isArabic ? h.source_ar : h.source_en
                        )
                    } else {
                        if let morning {
                            HadithCard(
                                title: L("حديث الصباح", "Morning Hadith"),
                                text: lang.isArabic ? morning.text_ar : morning.text_en,
                                source: lang.isArabic ? morning.source_ar : morning.source_en
                            )
                        }
                        if let evening {
                            HadithCard(
                                title: L("حديث المساء", "Evening Hadith"),
                                text: lang.isArabic ? evening.text_ar : evening.text_en,
                                source: lang.isArabic ? evening.source_ar : evening.source_en
                            )
                        }
                    }

                    if all.count < 2 {
                        Text(L("ملاحظة: أضف على الأقل حديثين داخل deen_json/hadith_collection.json",
                               "Note: Add at least 2 hadith inside deen_json/hadith_collection.json"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            .navigationTitle(L("حديث اليوم", "Hadith of the Day"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct HadithCard: View {
    let title: String
    let text: String
    let source: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            Text(text).font(.body)
            Divider()
            Text(source).font(.footnote).foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
