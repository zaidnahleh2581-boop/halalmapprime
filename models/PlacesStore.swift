//
//  PlacesStore.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/18/25
//

import Foundation
import Combine
import FirebaseFirestore

// MARK: - Place Link Option (for Ad linking)

struct PlaceLinkOption: Identifiable, Equatable {
    let id: String
    let name: String
    let cityState: String
    let categoryRaw: String

    static func from(doc: DocumentSnapshot) -> PlaceLinkOption {
        let data = doc.data() ?? [:]
        return PlaceLinkOption(
            id: doc.documentID,
            name: data["name"] as? String ?? "Unknown",
            cityState: data["cityState"] as? String ?? "",
            categoryRaw: data["category"] as? String ?? ""
        )
    }
}

// MARK: - Places Store

final class PlacesStore: ObservableObject {

    static let shared = PlacesStore()
    private init() {}

    @Published private(set) var places: [PlaceLinkOption] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// Start realtime listener for places (used for Ad linking picker)
    func startListener(limit: Int = 200) {
        listener?.remove()

        listener = db.collection("places")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                guard err == nil, let docs = snap?.documents else {
                    Task { @MainActor in
                        self.places = []
                    }
                    return
                }

                let mapped = docs.map { PlaceLinkOption.from(doc: $0) }

                Task { @MainActor in
                    self.places = mapped
                }
            }
    }

    func stopListener() {
        listener?.remove()
        listener = nil
    }
}
