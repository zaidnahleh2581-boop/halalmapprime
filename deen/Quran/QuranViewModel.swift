//
//  QuranViewModel.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import Foundation
import Combine

final class QuranViewModel: ObservableObject {
    @Published var surahs: [QuranSurah] = []

    init() {
        let root = QuranBundleLoader.loadQuran()
        self.surahs = root.surahs
        print("📖 QuranViewModel surahs count = \(surahs.count)")
    }
}
