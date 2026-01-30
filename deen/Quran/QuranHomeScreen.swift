//
//  QuranHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import SwiftUI

struct QuranHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var vm = QuranViewModel()
    @State private var query: String = ""

    private var filtered: [QuranSurah] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return vm.surahs }
        return vm.surahs.filter {
            $0.name_ar.contains(query) ||
            $0.name_en.lowercased().contains(q) ||
            String($0.id) == q
        }
    }

    var body: some View {
        VStack(spacing: 12) {

            // Search
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search surah (name / number)", text: $query)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if vm.surahs.isEmpty {
                Text("Qur'an data is empty — check bundle loading.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 20)
                Spacer()
            } else {
                List(filtered) { surah in
                    NavigationLink {
                        QuranSurahScreen(surah: surah)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lang.isArabic ? surah.name_ar : surah.name_en)
                                .font(.headline)
                            Text("Surah \(surah.id) • \(surah.ayahs.count) ayahs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle("Qur'an")
    }
}
