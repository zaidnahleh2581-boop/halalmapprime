//
//  QuranFavoritesScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct QuranFavoritesScreen: View {

    @StateObject private var vm = QuranFavoritesViewModel()
    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        List {

            if vm.favorites.isEmpty {
                Text(L("لا يوجد آيات مفضلة", "No favorite verses"))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 12)
            } else {
                ForEach(vm.favorites) { fav in
                    VStack(alignment: .leading, spacing: 8) {

                        Text(lang.isArabic ? fav.text_ar : fav.text_en)
                            .font(.body)
                            .multilineTextAlignment(lang.isArabic ? .trailing : .leading)
                            .frame(
                                maxWidth: .infinity,
                                alignment: lang.isArabic ? .trailing : .leading
                            )

                        Text(
                            lang.isArabic
                            ? "سورة \(fav.surahNameAr) – آية \(fav.ayah)"
                            : "Surah \(fav.surahNameEn) – Ayah \(fav.ayah)"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            vm.remove(fav)
                        } label: {
                            Label(L("حذف", "Remove"), systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(L("المفضلة", "Favorites"))
    }
}
