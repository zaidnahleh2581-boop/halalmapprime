//
//  EventAdsService.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Combine

/// خدمة إدارة إعلانات الفعاليات (القراءة / الكتابة) من وإلى Firestore
final class EventAdsService: ObservableObject {

    static let shared = EventAdsService()

    @Published private(set) var events: [EventAd] = []
    @Published var isLoading: Bool = false
    @Published var lastError: Error?

    private let collection = Firestore.firestore().collection("eventAds")
    private var listener: ListenerRegistration?

    private init() { }

    // MARK: - Realtime Listener

    func startListening() {
        listener?.remove()
        isLoading = true
        lastError = nil

        listener = collection
            .order(by: "eventDate", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    self.lastError = error
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.events = []
                    self.isLoading = false
                    return
                }

                self.events = documents.compactMap { doc in
                    let data = doc.data()

                    guard
                        let title = data["title"] as? String,
                        let city = data["city"] as? String,
                        let placeName = data["placeName"] as? String,
                        let description = data["description"] as? String,
                        let contact = data["contact"] as? String
                    else {
                        return nil
                    }

                    let eventTs = data["eventDate"] as? Timestamp ?? Timestamp(date: Date())
                    let createdTs = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())

                    return EventAd(
                        id: doc.documentID,
                        title: title,
                        city: city,
                        placeName: placeName,
                        eventDate: eventTs.dateValue(),
                        description: description,
                        contact: contact,
                        createdAt: createdTs.dateValue()
                    )
                }

                self.isLoading = false
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Create

    func publish(
        title: String,
        city: String,
        placeName: String,
        eventDate: Date,
        description: String,
        contact: String,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "title": title,
            "city": city,
            "placeName": placeName,
            "eventDate": Timestamp(date: eventDate),
            "description": description,
            "contact": contact,
            "createdAt": Timestamp(date: Date())
        ]

        collection.addDocument(data: data) { error in
            completion(error)
        }
    }
}
