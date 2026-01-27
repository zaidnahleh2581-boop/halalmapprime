//
//  FaithLocalStore.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//

import Foundation

enum FaithLocalStore {

    // MARK: - Bundle JSON (Strict: crashes if missing/invalid)
    static func loadCodable<T: Decodable>(
        _ type: T.Type,
        filename: String,
        subdirectory: String? = nil
    ) -> T {
        let bundle = Bundle.main

        let url: URL?
        if let sub = subdirectory {
            url = bundle.url(forResource: filename, withExtension: "json", subdirectory: sub)
        } else {
            url = bundle.url(forResource: filename, withExtension: "json")
        }

        guard let fileURL = url else {
            fatalError("❌ Missing JSON file: \(filename).json (subdir: \(subdirectory ?? "nil"))")
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError("❌ Failed to decode \(filename).json: \(error)")
        }
    }

    // MARK: - Bundle JSON (Safe: returns nil if missing/invalid)
    static func loadCodableSafe<T: Decodable>(
        _ type: T.Type,
        filename: String,
        subdirectory: String? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) -> T? {
        let bundle = Bundle.main

        let url: URL?
        if let sub = subdirectory {
            url = bundle.url(forResource: filename, withExtension: "json", subdirectory: sub)
        } else {
            url = bundle.url(forResource: filename, withExtension: "json")
        }

        guard let fileURL = url else {
            #if DEBUG
            print("❌ FaithLocalStore: Missing JSON file: \(filename).json (subdir: \(subdirectory ?? "nil"))")
            #endif
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("❌ FaithLocalStore: Decode failed for \(filename).json: \(error)")
            #endif
            return nil
        }
    }

    // ✅ Alias (عشان أي كود قديم بيناديها)
    static func loadCodableOrNil<T: Decodable>(
        _ type: T.Type,
        filename: String,
        subdirectory: String? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) -> T? {
        loadCodableSafe(type, filename: filename, subdirectory: subdirectory, decoder: decoder)
    }

    // MARK: - UserDefaults (Save/Load Codable)
    static func saveCodable<T: Encodable>(_ value: T, key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            #if DEBUG
            print("❌ saveCodable failed for key \(key): \(error)")
            #endif
        }
    }

    static func loadSavedCodable<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("❌ loadSavedCodable failed for key \(key): \(error)")
            #endif
            return nil
        }
    }

    static func removeSaved(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
