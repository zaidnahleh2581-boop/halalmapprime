//
//  QuranSurahScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//

import SwiftUI

struct QuranSurahScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @ObservedObject var vm: QuranViewModel
    let surahNumber: Int

    private var surah: QuranSurah? {
        vm.surahs.first { $0.id == surahNumber }
    }

    var body: some View {
        Group {
            if let surah = surah {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(surah.name_ar)
                                .font(.title2)
                                .bold()

                            Text(surah.name_en)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }

                    ForEach(surah.ayahs) { ayah in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(ayah.ar)
                                .font(.body)

                            if !ayah.en.isEmpty {
                                Text(ayah.en)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            } else {
                Text(L("السورة غير موجودة", "Surah not found"))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(L("سورة \(surahNumber)", "Surah \(surahNumber)"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
