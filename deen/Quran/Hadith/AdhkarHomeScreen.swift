//
//  AdhkarHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import SwiftUI
import Combine

// MARK: - Counter Store

final class AdhkarCounterStore: ObservableObject {

    @Published var counts: [String: Int]
    private let key = "adhkar_counts_v1"

    init() {
        counts = FaithLocalStore.loadSavedCodable([String:Int].self, key: key) ?? [:]
    }

    func inc(_ id: String) {
        counts[id, default: 0] += 1
        save()
    }

    func reset(_ id: String) {
        counts[id] = 0
        save()
    }

    func resetAll() {
        counts.removeAll()
        save()
    }

    private func save() {
        FaithLocalStore.saveCodable(counts, key: key)
    }
}

// MARK: - Main Screen

struct AdhkarHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @StateObject private var counter = AdhkarCounterStore()
    @State private var searchText: String = ""

    // ✅ تحميل آمن بدون crash
    private let root: AdhkarRoot

    init() {
        if let loaded = FaithLocalStore.loadCodableSafe(
            AdhkarRoot.self,
            filename: "deen_json_resources",
            subdirectory: "deen_json"
        ) {
            self.root = loaded
        } else {
            self.root = AdhkarRoot(categories: [])
            print("❌ Adhkar JSON failed to load")
        }
    }

    private var filteredCategories: [AdhkarCategory] {
        let cats = root.categories
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return cats }

        return cats.filter { c in
            (lang.isArabic ? c.title_ar : c.title_en)
                .localizedCaseInsensitiveContains(q)
            ||
            c.items.contains(where: { item in
                (lang.isArabic ? item.text_ar : item.text_en)
                    .localizedCaseInsensitiveContains(q)
            })
        }
    }

    var body: some View {
        NavigationStack {
            List {

                Section {
                    TextField(L("ابحث في الأذكار...", "Search adhkar..."), text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }

                if filteredCategories.isEmpty {
                    Text(L(
                        "لا يوجد أذكار حالياً.",
                        "No adhkar available."
                    ))
                    .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredCategories) { c in
                        NavigationLink {
                            AdhkarCategoryScreen(category: c)
                                .environmentObject(lang)
                                .environmentObject(counter)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(lang.isArabic ? c.title_ar : c.title_en)
                                    .font(.headline)
                                Text("\(c.items.count) \(L("ذكر", "items"))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        counter.resetAll()
                    } label: {
                        Label(
                            L("تصفير كل العدّادات", "Reset all counters"),
                            systemImage: "arrow.counterclockwise"
                        )
                    }
                }
            }
            .navigationTitle(L("الأذكار", "Adhkar"))
        }
    }
}

// MARK: - Category Screen

struct AdhkarCategoryScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var counter: AdhkarCounterStore

    let category: AdhkarCategory
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        List {
            ForEach(category.items) { item in
                VStack(alignment: .leading, spacing: 10) {

                    Text(lang.isArabic ? item.text_ar : item.text_en)
                        .font(.body)

                    HStack {
                        let current = counter.counts[item.id, default: 0]
                        Text("\(L("العدّاد", "Count")): \(current)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            counter.inc(item.id)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }

                        Button(role: .destructive) {
                            counter.reset(item.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .font(.caption)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle(lang.isArabic ? category.title_ar : category.title_en)
    }
}
