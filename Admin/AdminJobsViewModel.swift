//
//  AdminJobsViewModel.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//
import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class AdminJobsViewModel: ObservableObject {

    @Published var items: [AdminJobAd] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false

    @Published var showDeleteAlert: Bool = false
    @Published var deleteMessage: String = ""
    private var pendingDelete: AdminJobAd? = nil

    private let db = Firestore.firestore()
    private let pageSize = 30
    private var lastDoc: DocumentSnapshot? = nil
    private var reachedEnd = false

    func refresh() {
        isLoading = true
        reachedEnd = false
        lastDoc = nil
        items = []

        Task {
            do {
                let snap = try await baseQuery()
                    .limit(to: pageSize)
                    .getDocuments()

                self.lastDoc = snap.documents.last
                self.items = snap.documents.map { AdminJobAd(id: $0.documentID, data: $0.data()) }
                self.isLoading = false
                self.reachedEnd = snap.documents.count < self.pageSize
            } catch {
                self.isLoading = false
            }
        }
    }

    func loadMoreIfNeeded(current: AdminJobAd) {
        guard !isLoading, !isLoadingMore, !reachedEnd else { return }
        guard let last = items.last, last.id == current.id else { return }
        guard let lastDoc else { return }

        isLoadingMore = true
        Task {
            do {
                let snap = try await baseQuery()
                    .start(afterDocument: lastDoc)
                    .limit(to: pageSize)
                    .getDocuments()

                self.lastDoc = snap.documents.last
                let more = snap.documents.map { AdminJobAd(id: $0.documentID, data: $0.data()) }
                self.items.append(contentsOf: more)

                self.isLoadingMore = false
                self.reachedEnd = snap.documents.count < self.pageSize
            } catch {
                self.isLoadingMore = false
            }
        }
    }

    private func baseQuery() -> Query {
        db.collection("jobAds")
            .order(by: "createdAt", descending: true)
    }

    func toggleHidden(_ ad: AdminJobAd) {
        let newValue = !(ad.adminHidden ?? false)
        db.collection("jobAds").document(ad.id).updateData([
            "adminHidden": newValue,
            "adminHiddenAt": FieldValue.serverTimestamp()
        ])
    }

    func askDelete(_ ad: AdminJobAd) {
        pendingDelete = ad
        deleteMessage = "Delete this Job ad?\nID: \(ad.id)"
        showDeleteAlert = true
    }

    func confirmDelete() {
        guard let ad = pendingDelete else { return }
        pendingDelete = nil
        db.collection("jobAds").document(ad.id).delete()
    }
}
