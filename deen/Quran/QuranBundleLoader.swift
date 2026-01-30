//
//  QuranBundleLoader.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Updated by Zaid Nahleh on 2026-01-28.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

enum QuranBundleLoader {

    static func loadQuran() -> QuranRoot {

        // 1) جرّب أولاً مع subdirectory (deen_json)
        if let root: QuranRoot = tryLoad(QuranRoot.self, filename: "quran_local", subdirectory: "deen_json") {
            debug(root, source: "deen_json/quran_local.json")
            return root
        }

        // 2) إذا فشل، جرّب بدون subdirectory (لو Xcode عاملها Group وليس Folder)
        if let root: QuranRoot = tryLoad(QuranRoot.self, filename: "quran_local", subdirectory: nil) {
            debug(root, source: "main bundle / quran_local.json")
            return root
        }

        // 3) إذا فشل الاثنين، اطبع كل ملفات json الموجودة للمساعدة
        print("❌ QuranBundleLoader: FAILED to load quran_local.json from both locations.")
        debugPrintAllJSON()
        return QuranRoot(surahs: [])
    }

    private static func debug(_ root: QuranRoot, source: String) {
        print("📖 Quran loaded from: \(source)")
        print("📖 Quran surahs count = \(root.surahs.count)")

        if let first = root.surahs.first {
            print("📖 First surah: id=\(first.id) ar=\(first.name_ar) en=\(first.name_en) ayahs=\(first.ayahs.count)")
        } else {
            print("⚠️ Quran loaded BUT surahs is empty.")
        }
    }

    private static func tryLoad<T: Decodable>(_ type: T.Type, filename: String, subdirectory: String?) -> T? {
        let bundle = Bundle.main

        let url =
            bundle.url(forResource: filename, withExtension: "json", subdirectory: subdirectory)
            ?? bundle.url(forResource: filename, withExtension: "json")

        guard let fileURL = url else {
            print("⚠️ QuranBundleLoader: file not found \(filename).json subdir=\(subdirectory ?? "nil")")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            print("✅ QuranBundleLoader: loaded \(filename).json subdir=\(subdirectory ?? "nil") size=\(data.count) bytes")
            return decoded
        } catch {
            print("❌ QuranBundleLoader: decode failed \(filename).json subdir=\(subdirectory ?? "nil")")
            print("❌ error = \(error)")
            return nil
        }
    }

    private static func debugPrintAllJSON() {
        let all = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        print("📦 JSON files in main bundle:")
        all.forEach { print(" - \($0.lastPathComponent)") }

        let inDeen = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "deen_json") ?? []
        print("📦 JSON files in bundle/deen_json:")
        inDeen.forEach { print(" - \($0.lastPathComponent)") }
    }
}
