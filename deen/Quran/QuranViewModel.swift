//
//  QuranViewModel.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import Foundation
import Combine

final class QuranViewModel: ObservableObject {

    // Search
    @Published var query: String = ""

    // Display toggles
    @Published var showArabic: Bool = true
    @Published var showEnglish: Bool = true

    // Data
    @Published var surahs: [QuranSurah] = []

    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Favorites (optional)
    @Published var favorites: [Int] = []

    private enum Keys {
        static let filename = "quran_local"      // quran_local.json
        static let subdir = "deen_json"          // folder inside bundle
    }

    init() {
        loadQuran()
    }

    func loadQuran() {
        isLoading = true
        errorMessage = nil

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        // ✅ SAFE load (no crash)
        if let root: QuranRoot = FaithLocalStore.loadCodableOrNil(
            QuranRoot.self,
            filename: Keys.filename,
            subdirectory: Keys.subdir,
            decoder: decoder
        ) {
            self.surahs = root.surahs
            self.isLoading = false

            #if DEBUG
            print("✅ Quran loaded: \(root.surahs.count) surahs")
            #endif

        } else {
            self.surahs = []
            self.isLoading = false
            self.errorMessage = "Quran JSON missing or invalid"

            #if DEBUG
            print("❌ Quran JSON failed to load: \(Keys.subdir)/\(Keys.filename).json")
            #endif
        }
    }

    // Search filter
    var filteredSurahs: [QuranSurah] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return surahs }

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
