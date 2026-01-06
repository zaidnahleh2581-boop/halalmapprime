//
//  AdsStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-05.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine

@MainActor
final class AdsStore: ObservableObject {

    @Published var myAds: [HMPAd] = []

    private let adsKey = "HMP_myAds_local_v2"          // ✅ bump version
    private let freeGiftKey = "HMP_freeGiftUsed_v1"

    // Optional profile snapshot (simple)
    @Published var profileBusinessName: String? = nil
    @Published var profilePhone: String? = nil

    // MARK: - Computed
    var activeAds: [HMPAd] {
        // ✅ Sort: Prime first, then Monthly, then Weekly, then FreeOnce (or adjust as you like)
        let active = myAds.filter { $0.isActive }
        return active.sorted { a, b in
            let pa = planRank(a.plan)
            let pb = planRank(b.plan)
            if pa != pb { return pa < pb }
            return a.createdAt > b.createdAt
        }
    }

    var expiredAds: [HMPAd] {
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

    // MARK: - Free Gift
    var canUseFreeGift: Bool {
        !UserDefaults.standard.bool(forKey: freeGiftKey)
    }

    func markFreeGiftUsed() {
        UserDefaults.standard.set(true, forKey: freeGiftKey)
    }

    // MARK: - Load / Save
    func load() {
        if let data = UserDefaults.standard.data(forKey: adsKey),
           let decoded = try? JSONDecoder().decode([HMPAd].self, from: data) {
            myAds = decoded
        } else {
            myAds = []
        }

        // Profile snapshot (best effort)
        profileBusinessName = myAds.first?.businessName
        profilePhone = myAds.first?.phone
    }

    func save() {
        if let data = try? JSONEncoder().encode(myAds) {
            UserDefaults.standard.set(data, forKey: adsKey)
        }
    }

    // MARK: - Create Ad (LOCAL)
    func createAdFromDraft(draft: AdDraft, plan: HMPAdPlanKind) {

        let now = Date()
        let expires = Calendar.current.date(byAdding: .day, value: plan.durationDays, to: now) ?? now

        let ad = HMPAd(
            id: UUID().uuidString,
            ownerKey: "local",
            plan: plan,
            isFeatured: plan.isFeatured,
            audience: audienceKey(from: draft.selectedAudience),
            businessName: draft.businessName,
            headline: draft.headline,
            adText: draft.adText,
            phone: draft.phone,
            website: draft.website,
            addressHint: draft.addressHint,
            imageBase64s: draft.imageBase64s,   // ✅ SAVE IMAGES
            createdAt: now,
            expiresAt: expires
        )

        myAds.insert(ad, at: 0)

        // Update profile snapshot
        if !draft.businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            profileBusinessName = draft.businessName
        }
        if !draft.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            profilePhone = draft.phone
        }

        save()
    }

    private func audienceKey(from a: AdAudience) -> String {
        switch a {
        case .restaurants: return "restaurants"
        case .mosques:     return "mosques"
        case .shops:       return "shops"
        case .schools:     return "schools"
        }
    }
}
