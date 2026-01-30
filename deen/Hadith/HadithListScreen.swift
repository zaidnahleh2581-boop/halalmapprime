//
//  HadithListScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import SwiftUI

struct HadithListScreen: View {

    let items: [HadithItem]

    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        List {
            ForEach(items) { h in
                VStack(alignment: .leading, spacing: 8) {

                    // نص الحديث
                    Text(lang.isArabic ? h.text_ar : h.text_en)
                        .font(.body)
                        .multilineTextAlignment(.leading)

                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle(L("الأحاديث", "Hadiths"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

