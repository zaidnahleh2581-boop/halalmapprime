//
//  AdminAdsViewModel.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/25/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class AdminAdsViewModel: ObservableObject {

    struct AdminAdItem: Identifiable {
        let id: String

        let businessName: String
        let headline: String
        let ownerKey: String?

        let createdAt: Date?

        // admin override
        let adminHidden: Bool?
        let adminNote: String?

        // for pagination
        let snapshot: DocumentSnapshot
    }

    @Published var items: [AdminAdItem] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false

    @Published var showDeleteAlert: Bool = false
    private var pendingDelete: AdminAdItem?
    var deleteMessage: String = ""

    private let db = Firestore.firestore()
    private var lastDoc: DocumentSnapshot?

    func refresh() {
        Task {
            isLoading = true
            defer { isLoading = false }

            items.removeAll()
            lastDoc = nil

            await fetchPage(isFirst: true)
        }
    }

    func loadMoreIfNeeded(current: AdminAdItem) {
        guard let last = items.last, last.id == current.id else { return }
        guard !isLoadingMore, !isLoading else { return }

        Task { await fetchPage(isFirst: false) }
    }

    private func fetchPage(isFirst: Bool) async {
        isLoadingMore = !isFirst
        defer { isLoadingMore = false }

        do {
            var q: Query = db.collection("ads")
                .order(by: "createdAt", descending: true)
                .limit(to: 25)

            if let lastDoc, !isFirst {
                q = q.start(afterDocument: lastDoc)
            }

            let snap = try await q.getDocuments()
            guard !snap.documents.isEmpty else { return }
            lastDoc = snap.documents.last

            let newItems: [AdminAdItem] = snap.documents.map { doc in
                let d = doc.data()

                let businessName = (d["businessName"] as? String) ?? ""
                let headline = (d["headline"] as? String) ?? ""
                let ownerKey = (d["ownerKey"] as? String) ?? (d["ownerId"] as? String)

                let createdAt = (d["createdAt"] as? Timestamp)?.dateValue()

                let admin = d["admin"] as? [String: Any]
                let hidden = admin?["hidden"] as? Bool
                let note = admin?["note"] as? String

                return AdminAdItem(
                    id: doc.documentID,
                    businessName: businessName,
                    headline: headline,
                    ownerKey: ownerKey,
                    createdAt: createdAt,
                    adminHidden: hidden,
                    adminNote: note,
                    snapshot: doc
                )
            }

            items.append(contentsOf: newItems)

        } catch {
            // لو بدك نضيف Toast لاحقاً
            print("❌ Admin ads fetch error:", error.localizedDescription)
        }
    }

    func toggleHidden(_ ad: AdminAdItem) {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }

            let newHidden = !(ad.adminHidden ?? false)
            let payload: [String: Any] = [
                "admin": [
                    "hidden": newHidden,
                    "hiddenAt": FieldValue.serverTimestamp(),
                    "hiddenBy": uid,
                    "note": newHidden ? "Hidden by admin" : ""
                ]
            ]

            do {
                try await db.collection("ads").document(ad.id).setData(payload, merge: true)

                // update local list
                if let idx = items.firstIndex(where: { $0.id == ad.id }) {
                    let old = items[idx]
                    items[idx] = AdminAdItem(
                        id: old.id,
                        businessName: old.businessName,
                        headline: old.headline,
                        ownerKey: old.ownerKey,
                        createdAt: old.createdAt,
                        adminHidden: newHidden,
                        adminNote: newHidden ? "Hidden by admin" : "",
                        snapshot: old.snapshot
                    )
                }

            } catch {
                print("❌ toggleHidden error:", error.localizedDescription)
            }
        }
    }

    func askDelete(_ ad: AdminAdItem) {
        pendingDelete = ad
        deleteMessage = "\(ad.businessName.isEmpty ? "This ad" : ad.businessName)\nID: \(ad.id)"
        showDeleteAlert = true
    }

    func confirmDelete() {
        guard let ad = pendingDelete else { return }
        pendingDelete = nil

        Task {
            do {
                try await db.collection("ads").document(ad.id).delete()
                items.removeAll { $0.id == ad.id }
            } catch {
                print("❌ delete ad error:", error.localizedDescription)
            }
        }
    }
}
