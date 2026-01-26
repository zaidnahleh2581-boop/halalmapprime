//
//  AdminPlacesViewModel.swift
//  Halal Map Prime
//
//  FINAL – Stable Admin Places Logic
//  Created by Zaid Nahleh
//

import Foundation
import FirebaseFirestore
import Combine
import CoreLocation

@MainActor
final class AdminPlacesViewModel: ObservableObject {

    // MARK: - Models
    struct AdminPlace: Identifiable {
        let id: String

        let name: String
        let ownerName: String
        let categoryId: String

        let address: String
        let city: String
        let state: String

        let phone: String
        let website: String

        let latitude: Double
        let longitude: Double

        let approvalRequired: Bool
        let isApproved: Bool

        let createdAt: Date?
    }

    // MARK: - Published
    @Published var pending: [AdminPlace] = []
    @Published var approved: [AdminPlace] = []
    @Published var rejected: [AdminPlace] = []

    @Published var isLoading: Bool = false
    @Published var lastError: String? = nil

    private let db = Firestore.firestore()

    // MARK: - Load All
    func loadAll() {
        isLoading = true
        lastError = nil

        db.collection("places")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }

                Task { @MainActor in
                    self.isLoading = false

                    if let err {
                        self.lastError = err.localizedDescription
                        return
                    }

                    guard let docs = snap?.documents else {
                        self.pending = []
                        self.approved = []
                        self.rejected = []
                        return
                    }

                    var p: [AdminPlace] = []
                    var a: [AdminPlace] = []
                    var r: [AdminPlace] = []

                    for doc in docs {
                        let d = doc.data()

                        let approvalRequired = d["approvalRequired"] as? Bool ?? false
                        let isApproved = d["isApproved"] as? Bool ?? false

                        let place = AdminPlace(
                            id: doc.documentID,
                            name: d["name"] as? String ?? "",
                            ownerName: d["ownerName"] as? String ?? "",
                            categoryId: d["categoryId"] as? String ?? "",
                            address: d["address"] as? String ?? "",
                            city: d["city"] as? String ?? "",
                            state: d["state"] as? String ?? "",
                            phone: d["phone"] as? String ?? "",
                            website: d["website"] as? String ?? "",
                            latitude: d["latitude"] as? Double ?? 0,
                            longitude: d["longitude"] as? Double ?? 0,
                            approvalRequired: approvalRequired,
                            isApproved: isApproved,
                            createdAt: (d["createdAt"] as? Timestamp)?.dateValue()
                        )

                        if approvalRequired && !isApproved {
                            p.append(place)            // Pending (food)
                        } else if isApproved {
                            a.append(place)            // Approved
                        } else {
                            r.append(place)            // Rejected / hidden
                        }
                    }

                    self.pending = p
                    self.approved = a
                    self.rejected = r
                }
            }
    }

    // MARK: - Actions
    func approve(_ place: AdminPlace) {
        db.collection("places")
            .document(place.id)
            .setData([
                "isApproved": true,
                "approvedAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    func reject(_ place: AdminPlace) {
        db.collection("places")
            .document(place.id)
            .setData([
                "isApproved": false
            ], merge: true)
    }

    func delete(_ place: AdminPlace) {
        db.collection("places")
            .document(place.id)
            .delete()
    }
}
