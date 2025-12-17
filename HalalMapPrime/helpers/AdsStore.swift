//
//  AdsStore.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//  Updated by Zaid Nahleh on 12/17/25.
//

import Foundation
import Combine

final class AdsStore: ObservableObject {

    static let shared = AdsStore()

    @Published private(set) var ads: [Ad] = []

    private let storageFilename = "ads.json"
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadFromDisk()

        // أي تغيير على ads -> احفظ تلقائي
        $ads
            .dropFirst()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveToDisk()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public

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
            saveToDisk()
        }
    }

    // MARK: - Free Ad monthly cooldown

    /// يمنع Free Ad أكثر من مرة بالشهر لنفس "المالك"
    /// (حالياً نستخدم phone كـ key)
    func canCreateFreeAd(cooldownKey: String) -> Bool {
        let key = normalizeKey(cooldownKey)
        guard let last = ads
            .filter({ $0.tier == .free && normalizeKey($0.freeCooldownKey) == key })
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
        else { return true }

        let days30: TimeInterval = 30 * 24 * 60 * 60
        return Date().timeIntervalSince(last.createdAt) >= days30
    }

    func freeAdCooldownRemainingDays(cooldownKey: String) -> Int {
        let key = normalizeKey(cooldownKey)
        guard let last = ads
            .filter({ $0.tier == .free && normalizeKey($0.freeCooldownKey) == key })
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
        else { return 0 }

        let days30: TimeInterval = 30 * 24 * 60 * 60
        let elapsed = Date().timeIntervalSince(last.createdAt)
        let remaining = max(0, days30 - elapsed)
        return Int(ceil(remaining / (24 * 60 * 60)))
    }

    // MARK: - Disk Persistence (LOCAL)

    private func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func storageURL() -> URL {
        documentsURL().appendingPathComponent(storageFilename)
    }

    private func loadFromDisk() {
        let url = storageURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            ads = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder.hmpDecoder.decode([Ad].self, from: data)
            ads = decoded
        } catch {
            print("❌ AdsStore load error:", error)
            ads = []
        }
    }

    private func saveToDisk() {
        let url = storageURL()
        do {
            let data = try JSONEncoder.hmpEncoder.encode(ads)
            try data.write(to: url, options: .atomic)
        } catch {
            print("❌ AdsStore save error:", error)
        }
    }

    private func normalizeKey(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

// MARK: - JSON Date helpers
private extension JSONEncoder {
    static var hmpEncoder: JSONEncoder {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted]
        enc.dateEncodingStrategy = .iso8601
        return enc
    }
}

private extension JSONDecoder {
    static var hmpDecoder: JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }
}
