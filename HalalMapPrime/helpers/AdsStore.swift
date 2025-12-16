//
//  AdsStore.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import Foundation
import Combine

final class AdsStore: ObservableObject {

    static let shared = AdsStore()

    @Published private(set) var ads: [Ad] = []

    private init() { }

    // MARK: - Public helpers

    /// يرجّع فقط الإعلانات النشطة + غير المنتهية، مرتبة (Prime ثم Paid ثم Free) والأحدث أولاً
    func activeAdsSorted() -> [Ad] {
        expireAdsIfNeeded()

        return ads
            .filter { $0.status == .active && !$0.isExpired }
            .sorted { a, b in
                let ra = a.tier.priority
                let rb = b.tier.priority
                if ra != rb { return ra > rb }
                return a.createdAt > b.createdAt
            }
    }

    func add(_ ad: Ad) {
        ads.insert(ad, at: 0)
    }

    func remove(adId: String) {
        ads.removeAll { $0.id == adId }
    }

    // MARK: - Expiration

    private func expireAdsIfNeeded() {
        var changed = false
        for i in ads.indices {
            if ads[i].status == .active, ads[i].isExpired {
                ads[i].status = .expired
                changed = true
            }
        }
        if changed {
            objectWillChange.send()
        }
    }

    // MARK: - Free Ad monthly cooldown

    /// يمنع Free Ad أكثر من مرة بالشهر لنفس "المالك" (نستخدم phone كـ key)
    func canCreateFreeAd(cooldownKey: String) -> Bool {
        // آخر Free Ad لهذا الرقم
        guard let last = ads
            .filter({ $0.tier == .free && $0.freeCooldownKey == cooldownKey })
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
        else { return true }

        // 30 يوم
        let days30: TimeInterval = 30 * 24 * 60 * 60
        return Date().timeIntervalSince(last.createdAt) >= days30
    }

    /// الوقت المتبقي حتى يسمح Free Ad جديد
    func freeAdCooldownRemainingDays(cooldownKey: String) -> Int {
        guard let last = ads
            .filter({ $0.tier == .free && $0.freeCooldownKey == cooldownKey })
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
        else { return 0 }

        let days30: TimeInterval = 30 * 24 * 60 * 60
        let elapsed = Date().timeIntervalSince(last.createdAt)
        let remaining = max(0, days30 - elapsed)
        return Int(ceil(remaining / (24 * 60 * 60)))
    }
}
