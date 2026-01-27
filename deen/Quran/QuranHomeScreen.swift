//
//  QuranHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import SwiftUI

struct QuranHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @StateObject private var vm = QuranViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // ✅ Search
                HStack {
                    Image(systemName: "magnifyingglass")

                    TextField(
                        L("ابحث عن سورة (اسم / رقم)", "Search surah (name / number)"),
                        text: Binding(
                            get: { vm.query },
                            set: { vm.query = $0 }
                        )
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // ✅ Toggles
                HStack(spacing: 12) {
                    Toggle(L("عربي", "Arabic"), isOn: Binding(get: { vm.showArabic }, set: { vm.showArabic = $0 }))
                    Toggle(L("English", "English"), isOn: Binding(get: { vm.showEnglish }, set: { vm.showEnglish = $0 }))
                }
                .padding(.horizontal)

                // ✅ List
                List(vm.filteredSurahs, id: \.id) { s in
                    NavigationLink {
                        // إذا عندك شاشة اسمها QuranSurahScreen استخدمها:
                        QuranSurahScreen(vm: vm, surahNumber: s.id)

                        // إذا ما عندك، علّق السطر فوق وحط Placeholder مؤقت:
                        // Text("Surah \(s.id)")
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(s.id). \(s.name_ar)")
                                .font(.headline)

                            Text(s.name_en)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(L("القرآن", "Quran"))
        }
    }
}
