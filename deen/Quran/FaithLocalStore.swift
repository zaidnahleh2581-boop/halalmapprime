
//
//  FaithLocalStore.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//  Copyright © 2026 Zaid Nahleh.
//

import Foundation

enum FaithLocalStore {

    // MARK: - Bundle JSON (Read-only)
    static func loadCodable<T: Decodable>(_ type: T.Type,
                                         filename: String,
                                         subdirectory: String? = nil) -> T {
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

    // MARK: - UserDefaults (Save/Load Codable)
    static func saveCodable<T: Encodable>(_ value: T, key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ saveCodable failed for key \(key): \(error)")
        }
    }

    static func loadSavedCodable<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ loadSavedCodable failed for key \(key): \(error)")
            return nil
        }
    }

    static func removeSaved(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
