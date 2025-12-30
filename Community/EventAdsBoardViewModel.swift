//
//  EventAdsBoardViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-29.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class EventAdsBoardViewModel: ObservableObject {

    @Published var events: [EventAd] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func start() {
        isLoading = true
        errorMessage = nil

        listener?.remove()
        listener = EventAdsService.shared.observeUpcomingEvents { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                self.isLoading = false

                switch result {
                case .success(let items):
                    self.events = items
                case .failure(let error):
                    self.events = []
                    self.errorMessage = self.prettyError(error)
                }
            }
        }
    }

    func isOwner(_ ad: EventAd) -> Bool {
        Auth.auth().currentUser?.uid == ad.ownerId
    }

    func delete(_ ad: EventAd) {
        // ✅ الأمان الحقيقي: لازم الـ Rules تمنع غير صاحب الإعلان
        // لذلك بنمرر ownerId للخدمة (والخدمة تعمل تحقق + الـ Rules تعمل enforce)
        EventAdsService.shared.softDeleteEventAd(
            adId: ad.id,
            ownerId: ad.ownerId
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.errorMessage = self.prettyError(error)
                }
            }
        }
    }

    // MARK: - Helpers

    private func prettyError(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()

        if msg.contains("missing or insufficient permissions") {
            return "ليس لديك صلاحية لهذه العملية. تأكد أنك نفس المستخدم الذي أنشأ الإعلان."
        }

        // Firestore sometimes returns "requires an index"
        if msg.contains("requires an index") {
            return "الاستعلام يحتاج Index في Firestore. افتح رابط الـ Index من الكونسول وأنشئه."
        }

        return error.localizedDescription
    }
}
