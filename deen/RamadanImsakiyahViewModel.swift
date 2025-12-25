//
//  RamadanImsakiyahViewModel.swift
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
final class RamadanImsakiyahViewModel: ObservableObject {

    struct RamadanDay: Identifiable, Hashable {
        let id = UUID()
        let gregorianDate: String
        let hijriDate: String
        let imsak: String
        let fajr: String
        let maghrib: String
    }

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var days: [RamadanDay] = []
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var lastUpdated: Date? = nil
    @Published private(set) var cityLabel: String? = nil

    private let method = 2 // ISNA (USA)

    func loadIfNeeded(from location: CLLocation?) {
        guard let location else { return }
        if days.isEmpty {
            Task { await load(from: location, forceRefresh: false) }
        }
    }

    func refresh(from location: CLLocation?) {
        guard let location else { return }
        Task { await load(from: location, forceRefresh: true) }
    }

    private func load(from location: CLLocation, forceRefresh: Bool) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        await resolveCityLabelIfNeeded(from: location)

        do {
            let hijriYear = try await fetchHijriYearForToday()

            let lat = Self.round3(location.coordinate.latitude)
            let lon = Self.round3(location.coordinate.longitude)
            let cacheKey = "ramadan_imsakiyah_y\(hijriYear)_lat\(lat)_lon\(lon)_m\(method)"

            if !forceRefresh, let cached = loadCache(forKey: cacheKey) {
                self.days = cached.days
                self.lastUpdated = cached.updatedAt
                return
            }

            let fetched = try await fetchHijriRamadanCalendar(
                hijriMonth: 9,
                hijriYear: hijriYear,
                coordinate: location.coordinate
            )

            self.days = fetched
            self.lastUpdated = Date()
            saveCache(days: fetched, updatedAt: self.lastUpdated!, forKey: cacheKey)

        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Reverse geocode

    private func resolveCityLabelIfNeeded(from location: CLLocation) async {
        if cityLabel != nil { return }
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let p = placemarks.first {
                let city = p.locality
                let state = p.administrativeArea
                let parts = [city, state].compactMap { $0 }.joined(separator: ", ")
                if !parts.isEmpty { self.cityLabel = parts }
            }
        } catch { }
    }

    // MARK: - API

    private func fetchHijriYearForToday() async throws -> Int {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd-MM-yyyy"
        let todayStr = f.string(from: Date())

        let url = URL(string: "https://api.aladhan.com/v1/gToH/\(todayStr)")!
        let (data, _) = try await URLSession.shared.data(from: url)

        // حماية: إذا مش JSON
        guard data.first == UInt8(ascii: "{") else { throw URLError(.cannotParseResponse) }

        let decoded = try JSONDecoder().decode(GtoHResponse.self, from: data)
        guard let yearInt = Int(decoded.data.hijri.year) else { throw URLError(.cannotParseResponse) }
        return yearInt
    }

    private func fetchHijriRamadanCalendar(
        hijriMonth: Int,
        hijriYear: Int,
        coordinate: CLLocationCoordinate2D
    ) async throws -> [RamadanDay] {

        var comps = URLComponents(string: "https://api.aladhan.com/v1/hijriCalendar/\(hijriMonth)/\(hijriYear)")!
        comps.queryItems = [
            .init(name: "latitude", value: "\(coordinate.latitude)"),
            .init(name: "longitude", value: "\(coordinate.longitude)"),
            .init(name: "method", value: "\(method)")
        ]

        guard let url = comps.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard data.first == UInt8(ascii: "{") else { throw URLError(.cannotParseResponse) }

        let decoded = try JSONDecoder().decode(HijriCalendarResponse.self, from: data)

        let result: [RamadanDay] = decoded.data.compactMap { item in
            let g = item.date.gregorian
            let h = item.date.hijri
            let t = item.timings

            let monthNum = g.month.number.value
            let gStr = "\(g.year)-\(pad2(monthNum))-\(pad2(g.day))"
            let hStr = "\(h.day) \(h.month.en) \(h.year)"

            return RamadanDay(
                gregorianDate: gStr,
                hijriDate: hStr,
                imsak: clean(t.Imsak),
                fajr: clean(t.Fajr),
                maghrib: clean(t.Maghrib)
            )
        }

        return result
    }

    private func clean(_ s: String) -> String {
        if let idx = s.firstIndex(of: " ") { return String(s[..<idx]) }
        return s
    }

    private func pad2(_ n: Int) -> String { n < 10 ? "0\(n)" : "\(n)" }
    private func pad2(_ s: String) -> String {
        if let n = Int(s) { return pad2(n) }
        return s
    }

    private static func round3(_ v: Double) -> Double { (v * 1000).rounded() / 1000 }

    // MARK: - Cache

    private struct CachePayload: Codable {
        let days: [DayCodable]
        let updatedAt: Date
    }

    private struct DayCodable: Codable {
        let gregorianDate: String
        let hijriDate: String
        let imsak: String
        let fajr: String
        let maghrib: String
    }

    private func saveCache(days: [RamadanDay], updatedAt: Date, forKey key: String) {
        let payload = CachePayload(
            days: days.map { .init(gregorianDate: $0.gregorianDate, hijriDate: $0.hijriDate, imsak: $0.imsak, fajr: $0.fajr, maghrib: $0.maghrib) },
            updatedAt: updatedAt
        )
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadCache(forKey key: String) -> (days: [RamadanDay], updatedAt: Date)? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let payload = try? JSONDecoder().decode(CachePayload.self, from: data)
        else { return nil }

        let days = payload.days.map { RamadanDay(gregorianDate: $0.gregorianDate, hijriDate: $0.hijriDate, imsak: $0.imsak, fajr: $0.fajr, maghrib: $0.maghrib) }
        return (days, payload.updatedAt)
    }
}

// MARK: - Flexible Int (Int OR String)

private struct IntOrString: Codable {
    let value: Int

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let i = try? c.decode(Int.self) {
            value = i
            return
        }
        if let s = try? c.decode(String.self), let i = Int(s) {
            value = i
            return
        }
        throw DecodingError.typeMismatch(Int.self, .init(codingPath: decoder.codingPath, debugDescription: "Expected Int or String Int"))
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value)
    }
}

// MARK: - API Models (robust)

private struct GtoHResponse: Codable {
    let data: GtoHData
}
private struct GtoHData: Codable {
    let hijri: HijriLite
}
private struct HijriLite: Codable {
    let year: String
}

private struct HijriCalendarResponse: Codable {
    let data: [HijriCalendarItem]
}

private struct HijriCalendarItem: Codable {
    let timings: HijriTimings
    let date: HijriCalendarDate
}

private struct HijriTimings: Codable {
    let Imsak: String
    let Fajr: String
    let Maghrib: String
}

private struct HijriCalendarDate: Codable {
    let gregorian: GregorianDate
    let hijri: HijriDate
}

private struct GregorianDate: Codable {
    let day: String
    let month: GregorianMonth
    let year: String
}
private struct GregorianMonth: Codable {
    let number: IntOrString
}

private struct HijriDate: Codable {
    let day: String
    let month: HijriMonth
    let year: String
}
private struct HijriMonth: Codable {
    let en: String
}
