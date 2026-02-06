//
//  AdminEventsViewModel.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class AdminEventsViewModel: ObservableObject {

    @Published var items: [AdminEventItem] = []
    @Published var isLoading: Bool = false

    @Published var showDeleteAlert: Bool = false
    @Published var deleteMessage: String = ""
    private var pendingDelete: AdminEventItem? = nil

    private let db = Firestore.firestore()
    private let pageSize = 25

    func refresh() {
        isLoading = true
        items = []

        Task {
            do {
                async let a = fetch(collection: "eventAds", source: .eventAds)
                async let b = fetch(collection: "cityEventAds", source: .cityEventAds)

                let (listA, listB) = try await (a, b)
                let merged = (listA + listB).sorted {
                    ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
                }
                self.items = merged
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }

    private func fetch(collection: String, source: AdminEventSource) async throws -> [AdminEventItem] {
        let snap = try await db.collection(collection)
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize)
            .getDocuments()

        return snap.documents.map { AdminEventItem(id: $0.documentID, source: source, data: $0.data()) }
    }

    func toggleHidden(_ item: AdminEventItem) {
        let newValue = !(item.adminHidden ?? false)
        db.collection(item.source.rawValue).document(item.id).updateData([
            "adminHidden": newValue,
            "adminHiddenAt": FieldValue.serverTimestamp()
        ])
    }

    func askDelete(_ item: AdminEventItem) {
        pendingDelete = item
        deleteMessage = "Delete this Event?\n\(item.source.rawValue) • ID: \(item.id)"
        showDeleteAlert = true
    }

    func confirmDelete() {
        guard let item = pendingDelete else { return }
        pendingDelete = nil
        db.collection(item.source.rawValue).document(item.id).delete()
    }
}
