//
//  MapScreenViewModel.swift
//  Halal Map Prime
//
//  Clean Version – Firestore Only
//  Created by Zaid Nahleh
//

import Foundation
import MapKit
import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
final class MapScreenViewModel: ObservableObject {

    // MARK: - Published
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []
    @Published var isLoading: Bool = false
    @Published var lastErrorMessage: String? = nil

    private var listener: ListenerRegistration?

    // MARK: - Init
    init() {
        // ✅ لا تحميل تلقائي
    }

    // MARK: - Firestore (Approved Places Only)
    func startListeningToApprovedPlaces() {
        isLoading = true
        lastErrorMessage = nil

        listener?.remove()

        listener = Firestore.firestore()
            .collection("places")
            .whereField("isApproved", isEqualTo: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false

                    if let err {
                        self.places = []
                        self.filteredPlaces = []
                        self.lastErrorMessage = err.localizedDescription
                        return
                    }

                    let docs = snap?.documents ?? []

                    let loaded: [Place] = docs.compactMap { doc in
                        let d = doc.data()

                        guard
                            let name = d["name"] as? String,
                            let address = d["address"] as? String,
                            let cityState = d["cityState"] as? String,
                            let lat = d["latitude"] as? Double,
                            let lng = d["longitude"] as? Double
                        else { return nil }

                        return Place(
                            id: doc.documentID,
                            name: name,
                            address: address,
                            cityState: cityState,
                            latitude: lat,
                            longitude: lng,
                            category: .center, // عرض افتراضي
                            rating: 0,
                            reviewCount: 0,
                            deliveryAvailable: false,
                            isCertified: false,
                            phone: d["phone"] as? String,
                            website: d["website"] as? String,
                            adStatus: "free",
                            adPlan: "none",
                            adPriority: 0,
                            startAt: nil,
                            endAt: nil,
                            isAdActive: false
                        )
                    }

                    self.places = loaded
                    self.filteredPlaces = loaded
                }
            }
    }

    // MARK: - Search (Local Only)
    func filterBySearch(text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !q.isEmpty else {
            filteredPlaces = places
            return
        }

        filteredPlaces = places.filter {
            $0.name.lowercased().contains(q) ||
            $0.address.lowercased().contains(q)
        }
    }

    // MARK: - Focus
    func focus(on place: Place) {
        withAnimation {
            region = MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}
