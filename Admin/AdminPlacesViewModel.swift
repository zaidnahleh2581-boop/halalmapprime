//
//  AdminPlacesViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class AdminPlacesViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var pendingPlaces: [PlaceSubmission] = []

    @Published var lastError: String? = nil

    private let db = Firestore.firestore()

    func loadPending() {
        isLoading = true
        lastError = nil

        db.collection("place_submissions")
            .whereField("status", isEqualTo: "pending")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }

                Task { @MainActor in
                    self.isLoading = false

                    if let err = err {
                        self.lastError = err.localizedDescription
                        self.pendingPlaces = []
                        return
                    }

                    guard let docs = snap?.documents else {
                        self.pendingPlaces = []
                        return
                    }

                    // ✅ يحتاج FirebaseFirestoreSwift + PlaceSubmission: Codable
                    let items: [PlaceSubmission] = docs.compactMap { doc in
                        try? doc.data(as: PlaceSubmission.self)
                    }

                    self.pendingPlaces = items
                }
            }
    }

    func approve(_ item: PlaceSubmission) {
        guard let id = item.id else { return }

        db.collection("place_submissions")
            .document(id)
            .setData(["status": "approved"], merge: true)
    }

    func reject(_ item: PlaceSubmission) {
        guard let id = item.id else { return }

        db.collection("place_submissions")
            .document(id)
            .setData(["status": "rejected"], merge: true)
    }

    func delete(_ item: PlaceSubmission) {
        guard let id = item.id else { return }

        db.collection("place_submissions")
            .document(id)
            .delete()
    }
}
