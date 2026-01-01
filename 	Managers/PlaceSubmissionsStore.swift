//
//  PlaceSubmissionsStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import MapKit
import CoreLocation

@MainActor
final class PlaceSubmissionsStore: ObservableObject {

    static let shared = PlaceSubmissionsStore()

    @Published var isSubmitting: Bool = false
    @Published var lastError: String? = nil

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Gate Mode
    enum GateMode {
        /// Community monthly free slot (DEFAULT - keeps your existing behavior)
        case communityMonthly(phone: String?)

        /// Ads lifetime gift (one-time forever per place/location)
        case adsLifetimeGift

        /// No gate (for future paid ads flow, etc.)
        case none
    }

    enum SubmitError: LocalizedError {
        case lifetimeGiftAlreadyUsed

        var errorDescription: String? {
            switch self {
            case .lifetimeGiftAlreadyUsed:
                return "Lifetime free gift already used for this place."
            }
        }
    }

    // MARK: - Submit Place

    /// Submit a place (pending) + saves geo automatically
    /// Gate behavior:
    /// - communityMonthly: marks MonthlyFreeGate used (your existing behavior)
    /// - adsLifetimeGift: blocks if this placeKey already used, then marks Lifetime gate used
    func submitPlace(
        placeName: String,
        phone: String?,
        placeType: String,
        city: String,
        state: String,
        addressLine: String?,
        foodTruckStop: String?,
        gateMode: GateMode = .communityMonthly(phone: nil)
    ) async throws -> String {

        lastError = nil
        isSubmitting = true
        defer { isSubmitting = false }

        let uid = try await ensureUID()

        let fullAddress = buildFullAddress(
            addressLine: addressLine,
            city: city,
            state: state
        )

        // ✅ Geocode first (stronger against bypass)
        let coordinate = try await geocodeAddress(fullAddress)

        // ✅ Normalize address for stable identity
        let normalizedAddress = normalizeAddress(fullAddress)

        // ✅ Lifetime gift gate check (per place)
        var lifetimePlaceKey: String? = nil
        if case .adsLifetimeGift = gateMode {
            let key = LifetimeFreePlaceGate.shared.makePlaceKey(
                normalizedAddress: normalizedAddress,
                coordinate: coordinate
            )
            lifetimePlaceKey = key

            let ok = try await LifetimeFreePlaceGate.shared.canUse(placeKey: key)
            if !ok {
                throw SubmitError.lifetimeGiftAlreadyUsed
            }
        }

        var data: [String: Any] = [
            "ownerId": uid,
            "placeName": placeName,
            "placeType": placeType,
            "city": city,
            "state": state,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),

            // ✅ Geo for map pins
            "geo": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
            "lat": coordinate.latitude,
            "lng": coordinate.longitude
        ]

        let p = (phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !p.isEmpty { data["phone"] = p }

        let a = (addressLine ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !a.isEmpty { data["addressLine"] = a }

        let stop = (foodTruckStop ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !stop.isEmpty { data["foodTruckStop"] = stop }

        // ✅ Add submission
        let ref = try await db.collection("place_submissions").addDocument(data: data)

        // ✅ Mark gates AFTER successful submit
        switch gateMode {
        case .communityMonthly(let gatePhone):
            // keep your existing behavior
            try await MonthlyFreeGate.shared.markFreeUsed(phone: gatePhone ?? phone)

        case .adsLifetimeGift:
            if let key = lifetimePlaceKey {
                try await LifetimeFreePlaceGate.shared.markUsed(placeKey: key, payload: [
                    "firstOwnerId": uid,
                    "placeName": placeName,
                    "normalizedAddress": normalizedAddress,
                    "lat": round(coordinate.latitude * 10_000) / 10_000,
                    "lng": round(coordinate.longitude * 10_000) / 10_000
                ])
            }

        case .none:
            break
        }

        return ref.documentID
    }

    // MARK: - Auth

    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Missing UID"
                    ]))
                    return
                }
                cont.resume(returning: uid)
            }
        }
    }

    // MARK: - Helpers

    private func buildFullAddress(addressLine: String?, city: String, state: String) -> String {
        let a = (addressLine ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if a.isEmpty {
            return "\(city), \(state)"
        }
        return "\(a), \(city), \(state)"
    }

    private func normalizeAddress(_ address: String) -> String {
        let lower = address.lowercased()
        let cleaned = lower
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
        // collapse spaces
        let parts = cleaned.split(whereSeparator: { $0.isWhitespace })
        return parts.joined(separator: " ")
    }

    /// Geocoding using MapKit (MKLocalSearch)
    private func geocodeAddress(_ address: String) async throws -> CLLocationCoordinate2D {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        let search = MKLocalSearch(request: request)

        return try await withCheckedThrowingContinuation { cont in
            search.start { response, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                guard let item = response?.mapItems.first,
                      let coord = item.placemark.location?.coordinate
                else {
                    cont.resume(throwing: NSError(domain: "Geocode", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "Could not geocode address: \(address)"
                    ]))
                    return
                }
                cont.resume(returning: coord)
            }
        }
    }
}
