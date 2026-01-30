//
//  QuranSurahScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

// Disambiguate QuranSurah if multiple modules define it
typealias Surah = QuranSurah

struct QuranSurahScreen: View {

    @EnvironmentObject var lang: LanguageManager
    let surah: Surah

    var body: some View {
        List {

            // MARK: - Surah Header
            VStack(spacing: 6) {
                Text(surah.name_ar)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(surah.name_en)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowSeparator(.hidden)

            // MARK: - Ayahs
            ForEach(surah.ayahs) { ayah in
                VStack(alignment: .leading, spacing: 10) {

                    // Arabic text (always)
                    Text(ayah.ar)
                        .font(.title3)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // English translation (always)
                    Text(ayah.en)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Ayah number
                    Text("Ayah \(ayah.n)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
            }
        }
        .listStyle(.plain)
        .navigationTitle(surah.name_en)
        .navigationBarTitleDisplayMode(.inline)
    }
}
