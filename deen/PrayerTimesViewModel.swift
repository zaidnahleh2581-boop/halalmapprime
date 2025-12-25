//
//  PrayerTimesViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class PrayerTimesViewModel: ObservableObject {

    // MARK: - Published State
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var prayerTimes: [PrayerTime]? = nil
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var cityLabel: String? = nil
    @Published private(set) var lastUpdated: Date? = nil

    // MARK: - Settings
    private let method = 2 // ISNA (مناسب لأمريكا)

    // MARK: - Public API

    /// تحميل مرة واحدة (بدون ما يعيد طلب API إذا عندنا Cache لليوم)
    func loadIfPossible(from location: CLLocation?, isArabic: Bool) {
        guard let location else { return }
        if prayerTimes == nil {
            Task { await load(from: location, isArabic: isArabic, forceRefresh: false) }
        }
    }

    /// تحديث يدوي (Force refresh يتجاوز الكاش)
    func refresh(from location: CLLocation?, isArabic: Bool) {
        guard let location else { return }
        Task { await load(from: location, isArabic: isArabic, forceRefresh: true) }
    }

    // MARK: - Private

    private func load(from location: CLLocation, isArabic: Bool, forceRefresh: Bool) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // ✅ 1) City label (reverse geocode) — لا يمنع بقية العمل إذا فشل
        await resolveCityLabelIfNeeded(from: location)

        // ✅ 2) Cache key لليوم + تقريب الإحداثيات
        let dayKey = Self.dayKey(Date())
        let lat = Self.round3(location.coordinate.latitude)
        let lon = Self.round3(location.coordinate.longitude)
        let cacheKey = "prayers_\(dayKey)_\(lat)_\(lon)_m\(method)_\(isArabic ? "ar" : "en")"

        // ✅ 3) رجّع من الكاش إذا موجود (إلا إذا Force Refresh)
        if !forceRefresh, let cached = loadCache(forKey: cacheKey) {
            self.prayerTimes = cached.times
            self.lastUpdated = cached.updatedAt
            return
        }

        // ✅ 4) Fetch from API
        do {
            let fetched = try await fetchFromAPI(coordinate: location.coordinate, isArabic: isArabic)
            self.prayerTimes = fetched
            self.lastUpdated = Date()
            saveCache(times: fetched, updatedAt: self.lastUpdated!, forKey: cacheKey)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func fetchFromAPI(
        coordinate: CLLocationCoordinate2D,
        isArabic: Bool
    ) async throws -> [PrayerTime] {

        var comps = URLComponents(string: "https://api.aladhan.com/v1/timings")!
        comps.queryItems = [
            .init(name: "latitude", value: "\(coordinate.latitude)"),
            .init(name: "longitude", value: "\(coordinate.longitude)"),
            .init(name: "method", value: "\(method)")
        ]

        guard let url = comps.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(AlAdhanResponse.self, from: data)
        let t = decoded.data.timings

        // ✅ أسماء الصلوات حسب اللغة
        let fajrName = isArabic ? "الفجر" : "Fajr"
        let sunriseName = isArabic ? "الشروق" : "Sunrise"
        let dhuhrName = isArabic ? "الظهر" : "Dhuhr"
        let asrName = isArabic ? "العصر" : "Asr"
        let maghribName = isArabic ? "المغرب" : "Maghrib"
        let ishaName = isArabic ? "العشاء" : "Isha"

        return [
            PrayerTime(name: fajrName, time: clean(t.Fajr)),
            PrayerTime(name: sunriseName, time: clean(t.Sunrise)),
            PrayerTime(name: dhuhrName, time: clean(t.Dhuhr)),
            PrayerTime(name: asrName, time: clean(t.Asr)),
            PrayerTime(name: maghribName, time: clean(t.Maghrib)),
            PrayerTime(name: ishaName, time: clean(t.Isha))
        ]
    }

    // MARK: - Reverse Geocode (City)

    private func resolveCityLabelIfNeeded(from location: CLLocation) async {
        // لا نكرر كثير
        if cityLabel != nil { return }

        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let p = placemarks.first {
                let city = p.locality
                let state = p.administrativeArea
                let country = p.isoCountryCode

                let parts = [city, state].compactMap { $0 }.joined(separator: ", ")
                if !parts.isEmpty {
                    self.cityLabel = parts
                } else if let country {
                    self.cityLabel = country
                }
            }
        } catch {
            // ignore
        }
    }

    // MARK: - Cache (UserDefaults)

    private struct CachePayload: Codable {
        let times: [PrayerTimeCodable]
        let updatedAt: Date
    }

    private struct PrayerTimeCodable: Codable {
        let name: String
        let time: String
    }

    private func saveCache(times: [PrayerTime], updatedAt: Date, forKey key: String) {
        let payload = CachePayload(
            times: times.map { .init(name: $0.name, time: $0.time) },
            updatedAt: updatedAt
        )
        do {
            let data = try JSONEncoder().encode(payload)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // ignore cache failures
        }
    }

    private func loadCache(forKey key: String) -> (times: [PrayerTime], updatedAt: Date)? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        guard let payload = try? JSONDecoder().decode(CachePayload.self, from: data) else { return nil }
        let times = payload.times.map { PrayerTime(name: $0.name, time: $0.time) }
        return (times, payload.updatedAt)
    }

    // MARK: - Helpers

    private func clean(_ s: String) -> String {
        // API أحيانًا يرجّع "05:12 (EST)" → نشيل اللي بعد الفراغ
        if let idx = s.firstIndex(of: " ") {
            return String(s[..<idx])
        }
        return s
    }

    private static func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private static func round3(_ v: Double) -> Double {
        (v * 1000).rounded() / 1000
    }
}

// MARK: - API Models (داخلية، معزولة)
private struct AlAdhanResponse: Codable {
    let data: AlAdhanData
}
private struct AlAdhanData: Codable {
    let timings: AlAdhanTimings
}
private struct AlAdhanTimings: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
