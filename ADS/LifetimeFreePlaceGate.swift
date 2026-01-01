//
//  LifetimeFreePlaceGate.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import FirebaseFirestore
import CryptoKit
import MapKit

@MainActor
final class LifetimeFreePlaceGate {

    static let shared = LifetimeFreePlaceGate()
    private init() {}

    private let db = Firestore.firestore()

    enum GateError: LocalizedError {
        case alreadyUsed

        var errorDescription: String? {
            switch self {
            case .alreadyUsed:
                return "This place already used the lifetime free gift."
            }
        }
    }

    /// Create a stable place key from normalized address + rounded geo (prevents spouse-phone bypass).
    func makePlaceKey(normalizedAddress: String, coordinate: CLLocationCoordinate2D) -> String {
        let lat = round(coordinate.latitude * 10_000) / 10_000
        let lng = round(coordinate.longitude * 10_000) / 10_000
        let raw = "addr:\(normalizedAddress)|lat:\(lat)|lng:\(lng)"
        return sha256(raw)
    }

    /// Returns true if lifetime free gift is NOT used for this placeKey.
    func canUse(placeKey: String) async throws -> Bool {
        let ref = db.collection("free_lifetime_place_gate").document(placeKey)
        let snap = try await ref.getDocument()
        return !snap.exists
    }

    /// Mark as used (call only after successful submit).
    func markUsed(placeKey: String, payload: [String: Any]) async throws {
        try await db.collection("free_lifetime_place_gate").document(placeKey).setData([
            "usedAt": FieldValue.serverTimestamp(),
            "placeKey": placeKey
        ].merging(payload) { _, new in new }, merge: true)
    }

    // MARK: - Helpers

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
