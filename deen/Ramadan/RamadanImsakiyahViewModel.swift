//
//  RamadanImsakiyahViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class RamadanImsakiyahViewModel: ObservableObject {

    @Published var days: [RamadanImsakiyahDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var cityLabel: String?

    private let service = RamadanImsakiyahService()
    private var hasLoadedOnce = false

    func loadIfNeeded(from location: CLLocation?) {
        guard !hasLoadedOnce else { return }
        refresh(from: location)
    }

    func refresh(from location: CLLocation?) {
        guard let location else {
            self.errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetched = try await service.fetchRamadanDays(location: location, method: 2)
                self.days = fetched
                self.lastUpdated = Date()
                self.cityLabel = await reverseGeocodeCity(from: location)
                self.hasLoadedOnce = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }

    // MARK: - Reverse geocode (city label)

    private func reverseGeocodeCity(from location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            let p = placemarks.first
            let city = p?.locality
            let state = p?.administrativeArea
            let country = p?.country

            // Prefer: "Staten Island, NY" then fallback.
            if let city, let state { return "\(city), \(state)" }
            if let city { return city }
            if let state { return state }
            return country
        } catch {
            return nil
        }
    }
}
