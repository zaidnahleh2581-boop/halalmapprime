//
//  JobAdsService.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Combine

/// خدمة إدارة إعلانات الوظائف (القراءة / الكتابة) من وإلى Firestore
final class JobAdsService: ObservableObject {

    static let shared = JobAdsService()

    @Published private(set) var ads: [JobAd] = []
    @Published var isLoading: Bool = false
    @Published var lastError: Error?

    private let collection = Firestore.firestore().collection("jobAds")
    private var listener: ListenerRegistration?

    private init() { }

    // MARK: - Realtime Listener

    func startListening() {
        listener?.remove()
        isLoading = true
        lastError = nil

        listener = collection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    self.lastError = error
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.ads = []
                    self.isLoading = false
                    return
                }

                let now = Date()

                self.ads = documents.compactMap { doc in
                    let data = doc.data()

                    guard
                        let typeRaw   = data["type"] as? String,
                        let sectorRaw = data["sector"] as? String,
                        let title     = data["title"] as? String,
                        let details   = data["details"] as? String,
                        let city      = data["city"] as? String,
                        let contact   = data["contact"] as? String,
                        let ownerName = data["ownerName"] as? String,
                        let isFree    = data["isFree"] as? Bool,
                        let templateId = data["templateId"] as? Int
                    else {
                        return nil
                    }

                    let type = JobAdType(rawValue: typeRaw) ?? .hiring
                    let sector = JobSector(rawValue: sectorRaw) ?? .shops

                    let createdTs = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
                    let expiresTs = data["expiresAt"] as? Timestamp ??
                        Timestamp(date: createdTs.dateValue().addingTimeInterval(7 * 24 * 60 * 60))

                    let createdAt = createdTs.dateValue()
                    let expiresAt = expiresTs.dateValue()

                    // نخفي الإعلانات المنتهية (بعد ٧ أيام)
                    guard expiresAt >= now else {
                        return nil
                    }

                    return JobAd(
                        id: doc.documentID,
                        type: type,
                        sector: sector,
                        templateId: templateId,
                        title: title,
                        details: details,
                        city: city,
                        contact: contact,
                        ownerName: ownerName,
                        createdAt: createdAt,
                        expiresAt: expiresAt,
                        isFree: isFree
                    )
                }

                self.isLoading = false
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - قواعد الإعلانات المجانية

    /// يتحقق إذا كان المستخدم يستطيع نشر إعلان مجاني حسب القواعد:
    /// - باحث عن عمل: مرة مجانية كل 30 يوم
    /// - صاحب عمل: أول إعلان فقط مجاني
    func canPostFreeAd(
        ownerPhone: String,
        type: JobAdType,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let baseQuery = collection
            .whereField("ownerPhone", isEqualTo: ownerPhone)
            .whereField("type", isEqualTo: type.rawValue)
            .whereField("isFree", isEqualTo: true)

        let query: Query

        switch type {
        case .lookingForJob:
            // باحث عن عمل: إعلان مجاني واحد خلال آخر 30 يوم
            let now = Date()
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
            query = baseQuery.whereField("createdAt", isGreaterThan: Timestamp(date: thirtyDaysAgo))

        case .hiring:
            // صاحب عمل: أول إعلان مجاني فقط (مرة واحدة في العمر)
            query = baseQuery
        }

        query.getDocuments { snapshot, error in
            if let error {
                print("Error checking free quota: \(error.localizedDescription)")
                completion(false, "لا يمكن التحقق من حالة الإعلان المجاني حالياً، حاول لاحقاً.")
                return
            }

            let count = snapshot?.documents.count ?? 0

            switch type {
            case .lookingForJob:
                if count > 0 {
                    completion(false, "يمكنك نشر إعلان مجاني واحد فقط كل 30 يوم. يمكنك المحاولة لاحقاً أو استخدام إعلان مدفوع في المستقبل.")
                } else {
                    completion(true, nil)
                }

            case .hiring:
                if count > 0 {
                    completion(false, "استخدمت الإعلان المجاني لصاحب العمل. الإعلانات القادمة ستكون مدفوعة.")
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Create

    /// نشر إعلان جديد (مجاني أو مدفوع) – منطق التحقق المجاني يتم في الـ View
    func publish(
        type: JobAdType,
        sector: JobSector,
        templateId: Int,
        title: String,
        details: String,
        city: String,
        ownerName: String,
        ownerPhone: String,
        isFree: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        let now = Date()
        let expiresAt = now.addingTimeInterval(7 * 24 * 60 * 60) // ٧ أيام

        let data: [String: Any] = [
            "type": type.rawValue,
            "sector": sector.rawValue,
            "templateId": templateId,
            "title": title,
            "details": details,
            "city": city,
            "contact": ownerPhone,
            "ownerName": ownerName,
            "ownerPhone": ownerPhone,
            "isFree": isFree,
            "createdAt": Timestamp(date: now),
            "expiresAt": Timestamp(date: expiresAt)
        ]

        collection.addDocument(data: data) { error in
            completion(error)
        }
    }
}
