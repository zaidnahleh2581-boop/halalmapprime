//
//  MapScreenViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import MapKit
import SwiftUI
import Combine

@MainActor
final class MapScreenViewModel: ObservableObject {

    // MARK: - Published
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []
    @Published var isLoading: Bool = false
    @Published var lastErrorMessage: String? = nil

    // MARK: - Init
    init() {
        loadInitialData()
    }

    // MARK: - Initial Load
    func loadInitialData() {
        isLoading = true
        lastErrorMessage = nil

        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: nil
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let loaded):
                    let sorted = self.sortPlaces(loaded)
                    self.places = sorted
                    self.filteredPlaces = sorted
                case .failure(let error):
                    self.places = []
                    self.filteredPlaces = []
                    self.lastErrorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Search Nearby by Category (Google)
    func searchNearby(category: PlaceCategory?) {
        isLoading = true
        lastErrorMessage = nil

        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: category
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let loaded):
                    let sorted = self.sortPlaces(loaded)
                    self.places = sorted
                    self.filteredPlaces = sorted
                case .failure(let error):
                    self.places = []
                    self.filteredPlaces = []
                    self.lastErrorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - ✅ REQUIRED by MapScreen
    /// Yelp-style search:
    /// - If query is empty → reload nearby for selected category
    /// - Else → filter locally inside already loaded places (name/address)
    func searchByText(
        query: String,
        category: PlaceCategory?,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !q.isEmpty else {
            searchNearby(category: category)
            completion(.success(filteredPlaces))
            return
        }

        filterBySearch(text: q)
        completion(.success(filteredPlaces))
    }

    // MARK: - Local Filter (keeps sorting)
    func filterBySearch(text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !q.isEmpty else {
            filteredPlaces = places
            return
        }

        let filtered = places.filter {
            $0.name.lowercased().contains(q) ||
            $0.address.lowercased().contains(q)
        }

        // ✅ مهم: حتى بعد الفلترة، الإعلانات تبقى فوق
        filteredPlaces = sortPlaces(filtered)
    }

    // MARK: - Focus Map
    func focus(on place: Place) {
        withAnimation {
            region = MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}

// MARK: - Sorting
private extension MapScreenViewModel {

    /// Ranking:
    /// 1) isAdActive (true first)
    /// 2) adPlan (prime > monthly > weekly > none/empty)
    /// 3) rating (high first)
    /// 4) reviewCount (high first)
    /// 5) name (A-Z)
    func sortPlaces(_ input: [Place]) -> [Place] {
        input.sorted { a, b in

            // 1) Active Ad first
            if a.isAdActive != b.isAdActive {
                return a.isAdActive && !b.isAdActive
            }

            // 2) Plan priority
            let ap = planPriority(a.adPlan)
            let bp = planPriority(b.adPlan)
            if ap != bp { return ap > bp }

            // 3) Rating
            if a.rating != b.rating { return a.rating > b.rating }

            // 4) Reviews
            if a.reviewCount != b.reviewCount { return a.reviewCount > b.reviewCount }

            // 5) Name
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }

    func planPriority(_ plan: String) -> Int {
        let p = plan.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch p {
        case "prime", "prime_ad", "primead", "prime plan":
            return 3
        case "monthly", "monthly_ad", "monthlyad":
            return 2
        case "weekly", "weekly_ad", "weeklyad":
            return 1
        default:
            return 0
        }
    }
} 
