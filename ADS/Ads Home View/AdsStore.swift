//
//  AdsStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-13.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class AdsStore: ObservableObject {

    @Published var publicAds: [HMPAd] = []
    @Published var myAds: [HMPAd] = []

    @Published var isLoading: Bool = false
    @Published var lastError: String? = nil

    @Published var profileBusinessName: String? = nil
    @Published var profilePhone: String? = nil

    private let db = Firestore.firestore()

    private let freeGiftKey = "HMP_freeGiftUsed_v1"

    var activePublicAds: [HMPAd] {
        let active = publicAds.filter { $0.isActive }
        return active.sorted { a, b in
            let pa = planRank(a.plan)
            let pb = planRank(b.plan)
            if pa != pb { return pa < pb }
            return a.createdAt > b.createdAt
        }
    }

    var activeMyAds: [HMPAd] {
        let active = myAds.filter { $0.isActive }
        return active.sorted { a, b in
            let pa = planRank(a.plan)
            let pb = planRank(b.plan)
            if pa != pb { return pa < pb }
            return a.createdAt > b.createdAt
        }
    }

    var expiredMyAds: [HMPAd] {
        myAds.filter { !$0.isActive }.sorted { $0.expiresAt > $1.expiresAt }
    }

    private func planRank(_ p: HMPAdPlanKind) -> Int {
        switch p {
        case .prime: return 0
        case .monthly: return 1
        case .weekly: return 2
        case .freeOnce: return 3
        }
    }

    var canUseFreeGift: Bool {
        !UserDefaults.standard.bool(forKey: freeGiftKey)
    }

    func markFreeGiftUsed() {
        UserDefaults.standard.set(true, forKey: freeGiftKey)
    }

    func load() {
        Task {
            await loadPublic()
            await loadMyAds()
        }
    }

    /// ✅ updated signature (Draft + images)
    func createAdFromDraft(draft: AdDraft, plan: HMPAdPlanKind, imageDatas: [Data]) {
        Task { await createAdFromDraftAsync(draft: draft, plan: plan, imageDatas: imageDatas) }
    }

    // MARK: - Firestore Loads
    func loadPublic() async {
        lastError = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await ensureUID()

            let snap = try await db.collection("ads")
                .whereField("expiresAt", isGreaterThan: Timestamp(date: Date()))
                .order(by: "expiresAt", descending: false)
                .limit(to: 200)
                .getDocuments()

            self.publicAds = snap.documents.compactMap { decodeAd($0) }
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func loadMyAds() async {
        lastError = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await ensureUID()

            let snap = try await db.collection("ads")
                .whereField("ownerId", isEqualTo: uid)
                .order(by: "createdAt", descending: true)
                .limit(to: 200)
                .getDocuments()

            self.myAds = snap.documents.compactMap { decodeAd($0) }

            self.profileBusinessName = self.myAds.first?.businessName
            self.profilePhone = self.myAds.first?.phone
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    // MARK: - Firestore Create (Storage + imageURLs)
    private func createAdFromDraftAsync(draft: AdDraft, plan: HMPAdPlanKind, imageDatas: [Data]) async {
        lastError = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await ensureUID()

            let now = Date()
            let expires = Calendar.current.date(byAdding: .day, value: plan.durationDays, to: now) ?? now

            let ref = db.collection("ads").document()
            let adId = ref.documentID

            // ✅ Upload images to Storage (0..4) then store URLs in Firestore
            let imgs = Array(imageDatas.prefix(4))
            let urls: [String] = try await AdImageUploader.upload(images: imgs, ownerId: uid, adId: adId)

            let data: [String: Any] = [
                "id": adId,

                "ownerId": uid,
                "ownerKey": uid,

                "plan": plan.rawValue,
                "isFeatured": plan.isFeatured,
                "audience": audienceKey(from: draft.selectedAudience),

                "businessName": draft.businessName,
                "headline": draft.headline,
                "adText": draft.adText,

                "phone": draft.phone,
                "website": draft.website,
                "addressHint": draft.addressHint,

                // ✅ NEW (no base64)
                "imageURLs": urls,

                "createdAt": Timestamp(date: now),
                "expiresAt": Timestamp(date: expires)
            ]

            try await ref.setData(data, merge: false)

            await loadPublic()
            await loadMyAds()
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    private func audienceKey(from a: AdAudience) -> String {
        switch a {
        case .restaurants: return "restaurants"
        case .mosques:     return "mosques"
        case .shops:       return "shops"
        case .schools:     return "schools"
        }
    }

    // MARK: - Auth
    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Missing UID"
                    ]))
                    return
                }
                cont.resume(returning: uid)
            }
        }
    }

    // MARK: - Decode
    private func decodeAd(_ doc: QueryDocumentSnapshot) -> HMPAd? {
        let d = doc.data()
        let id = (d["id"] as? String) ?? doc.documentID

        guard
            let ownerKey = (d["ownerKey"] as? String) ?? (d["ownerId"] as? String),
            let planRaw = d["plan"] as? String,
            let plan = HMPAdPlanKind(rawValue: planRaw),
            let isFeatured = d["isFeatured"] as? Bool,
            let audience = d["audience"] as? String,
            let businessName = d["businessName"] as? String,
            let headline = d["headline"] as? String,
            let adText = d["adText"] as? String,
            let createdAtTS = d["createdAt"] as? Timestamp,
            let expiresAtTS = d["expiresAt"] as? Timestamp
        else {
            return nil
        }

        let phone = (d["phone"] as? String) ?? ""
        let website = (d["website"] as? String) ?? ""
        let addressHint = (d["addressHint"] as? String) ?? ""

        // ✅ NEW (preferred)
        let imageURLs = (d["imageURLs"] as? [String]) ?? []

        // ✅ Legacy support only (old docs)
        let imageBase64s = (d["imageBase64s"] as? [String]) ?? []

        return HMPAd(
            id: id,
            ownerKey: ownerKey,
            plan: plan,
            isFeatured: isFeatured,
            audience: audience,
            businessName: businessName,
            headline: headline,
            adText: adText,
            phone: phone,
            website: website,
            addressHint: addressHint,
            imageBase64s: imageBase64s,
            imageURLs: imageURLs,
            createdAt: createdAtTS.dateValue(),
            expiresAt: expiresAtTS.dateValue()
        )
    }
}
