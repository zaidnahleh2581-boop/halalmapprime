//
//  FaithLocalStore.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

enum FaithLocalStore {

    // MARK: - Bundle JSON (Safe)

    /// Loads a bundled JSON file and decodes it. Tries:
    /// 1) (subdirectory) path
    /// 2) top-level bundle (without subdirectory)
    ///
    /// Returns nil if missing or decode fails.
    static func loadBundledCodableOrNil<T: Decodable>(
        _ type: T.Type,
        filename: String,
        subdirectory: String? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) -> T? {

        decoder.keyDecodingStrategy = .useDefaultKeys

        // Try: subdirectory first (if provided)
        if let sub = subdirectory,
           let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: sub) {
            do {
                let data = try Data(contentsOf: url)
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ FaithLocalStore: Decode failed for \(sub)/\(filename).json — \(error)")
                return nil
            }
        }

        // Try: top-level bundle
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ FaithLocalStore: Decode failed for \(filename).json (top-level) — \(error)")
                return nil
            }
        }

        // Not found anywhere
        if let sub = subdirectory {
            print("⚠️ FaithLocalStore: JSON not found: \(filename).json (subdir: \(sub)) — also not found top-level")
        } else {
            print("⚠️ FaithLocalStore: JSON not found: \(filename).json (top-level)")
        }

        return nil
    }

    /// Same as above but returns a fallback instead of nil.
    static func loadBundledCodableSafe<T: Decodable>(
        _ type: T.Type,
        filename: String,
        subdirectory: String? = nil,
        fallback: T,
        decoder: JSONDecoder = JSONDecoder()
    ) -> T {
        return loadBundledCodableOrNil(type, filename: filename, subdirectory: subdirectory, decoder: decoder) ?? fallback
    }

    // MARK: - UserDefaults Codable (Safe)

    static func saveCodable<T: Encodable>(_ value: T, key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ FaithLocalStore: saveCodable failed for key=\(key) — \(error)")
        }
    }

    static func loadSavedCodable<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ FaithLocalStore: loadSavedCodable failed for key=\(key) — \(error)")
            return nil
        }
    }
}
