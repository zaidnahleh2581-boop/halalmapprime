//
//  QuranViewModel.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import Foundation
import Combine

final class QuranViewModel: ObservableObject {

    // ✅ هذا كان ناقص وهو سبب كل البلا
    @Published var query: String = ""

    // ✅ إعدادات العرض
    @Published var showArabic: Bool = true
    @Published var showEnglish: Bool = true

    // ✅ بيانات القرآن
    @Published var surahs: [QuranSurah] = []

    // ✅ المفضلة (آيات)
    @Published var favorites: [Int] = []

    init() {
        // تحميل القرآن من JSON
        let root: QuranRoot = FaithLocalStore.loadCodable(
            QuranRoot.self,
            filename: "quran_local",
            subdirectory: "deen_json"
        )

        self.surahs = root.surahs
    }

    // ✅ فلترة البحث
    var filteredSurahs: [QuranSurah] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if q.isEmpty {
            return surahs
        }

        // بحث برقم السورة
        if let num = Int(q),
           let found = surahs.first(where: { $0.id == num }) {
            return [found]
        }

        let qLower = q.lowercased()
        return surahs.filter {
            $0.name_ar.contains(q) ||
            $0.name_en.lowercased().contains(qLower)
        }
    }
}
