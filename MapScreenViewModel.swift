//
//  MapScreenViewModel.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/12/25.
//

import Foundation
import MapKit
import Combine
import SwiftUI

final class MapScreenViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    /// أماكن جايه من Google
    @Published private(set) var places: [Place] = []

    /// أماكن يضيفها المستخدم من داخل التطبيق (تظهر فورًا)
    @Published private(set) var userPlaces: [Place] = []

    /// نتائج العرض النهائية (Google + User)
    @Published var filteredPlaces: [Place] = []

    init() {
        loadInitialData()
    }

    // MARK: - Load initial Google data
    func loadInitialData() {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = self.mergeAndSort(google: loaded, user: self.userPlaces)
                    print("[MapScreenViewModel] Loaded \(loaded.count) places")
                case .failure(let error):
                    print("❌ Error: \(error)")
                }
            }
        }
    }

    // MARK: - Search by Category
    func searchNearby(category: PlaceCategory?) {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: category
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    let base = self.mergeAndSort(google: loaded, user: self.userPlaces)
                    self.filteredPlaces = self.applyCategoryFilter(base, category: category)
                case .failure(let error):
                    print("❌ Category search error: \(error)")
                }
            }
        }
    }

    // MARK: - Add place (User)
    func addUserPlace(_ place: Place) {
        userPlaces.insert(place, at: 0)
        // بعد الإضافة، نعمل refresh سريع للعرض
        filteredPlaces = mergeAndSort(google: places, user: userPlaces)
    }

    // MARK: - Filter by Search Text
    func filterBySearch(text: String) {
        let base = mergeAndSort(google: places, user: userPlaces)
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredPlaces = base
        } else {
            let q = text.lowercased()
            filteredPlaces = base.filter {
                $0.name.lowercased().contains(q) ||
                $0.address.lowercased().contains(q) ||
                $0.cityState.lowercased().contains(q)
            }
        }
    }

    // MARK: - Focus map on selected place
    func focus(on place: Place) {
        withAnimation {
            region = MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }

    // MARK: - Helpers
    private func mergeAndSort(google: [Place], user: [Place]) -> [Place] {
        // userPlaces أولًا ثم google
        return user + google
    }

    private func applyCategoryFilter(_ list: [Place], category: PlaceCategory?) -> [Place] {
        guard let category else { return list }
        return list.filter { $0.category == category }
    }
}
