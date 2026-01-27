//
//  QuranFavoritesScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//

import SwiftUI

struct QuranFavoritesScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @ObservedObject var vm: QuranViewModel

    // ✅ Favorites are stored as [Int] (ayah numbers)
    private var favAyahs: [QuranAyah] {
        vm.surahs
            .flatMap { surah in
                surah.ayahs.filter { vm.favorites.contains($0.n) }
            }
    }

    var body: some View {
        List {
            if favAyahs.isEmpty {
                Text(L("لا يوجد مفضلة بعد", "No favorites yet."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(favAyahs) { ayah in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lang.isArabic ? ayah.ar : ayah.en)
                            .font(.body)

                        Text(L("رقم الآية: \(ayah.n)", "Ayah #\(ayah.n)"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle(L("المفضلة", "Favorites"))
    }
}
