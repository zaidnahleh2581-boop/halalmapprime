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
import Combine   // ✅ هذا السطر هو الحل

@MainActor
final class RamadanImsakiyahViewModel: ObservableObject {

    struct RamadanDay: Identifiable, Equatable {
        let id: String

        let date: Date
        let gregorianDate: String
        let hijriDate: String

        let imsak: String
        let fajr: String
        let sunrise: String
        let dhuhr: String
        let asr: String
        let maghrib: String
        let isha: String
    }

    @Published var days: [RamadanDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var cityLabel: String? = nil
    @Published var lastUpdated: Date? = nil

    // MARK: - Public API

    func loadIfNeeded(from location: CLLocation?) {
        guard !isLoading else { return }
        guard days.isEmpty else { return }
        refresh(from: location)
    }

    func refresh(from location: CLLocation?) {
        guard !isLoading else { return }
        guard let location else {
            errorMessage = "Location not available yet."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (city, country) = try await reverseGeocodeCityCountry(for: location)
                self.cityLabel = [city, country].compactMap { $0 }.joined(separator: ", ")

                let ramadanDays = try await fetchRamadanDays(lat: location.coordinate.latitude,
                                                             lon: location.coordinate.longitude)

                self.days = ramadanDays
                self.lastUpdated = Date()
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Fetch Ramadan Days (Robust approach)
    // We fetch Gregorian months (calendar endpoint) and collect days where Hijri month == 9 (Ramadan).
    // This works regardless of what month we're currently in.

    private func fetchRamadanDays(lat: Double, lon: Double) async throws -> [RamadanDay] {

        // Start from current month/year and keep fetching forward until we collect Ramadan days.
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month], from: Date())
        guard var year = comps.year, var month = comps.month else {
            throw NSError(domain: "RamadanVM", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid current date."])
        }

        var found: [RamadanDay] = []
        var targetHijriYear: Int? = nil

        // We'll scan up to 14 months ahead to be safe
        for _ in 0..<14 {
            let response = try await fetchCalendarMonth(lat: lat, lon: lon, month: month, year: year)

            // Filter Ramadan days (Hijri month number == 9)
            let ramadanInThisMonth = response.data.compactMap { day -> RamadanDay? in
                guard day.date.hijri.month.number == 9 else { return nil }

                // Fix target hijri year on first hit
                if targetHijriYear == nil {
                    targetHijriYear = Int(day.date.hijri.year)
                }
                // Keep only the same Hijri year Ramadan
                let hijriYearInt = Int(day.date.hijri.year) ?? -1
                guard hijriYearInt == targetHijriYear else { return nil }

                let gregDateString = day.date.gregorian.date
                let parseGregorianDate: (String) -> Date? = { s in
                    let f = DateFormatter()
                    f.locale = Locale(identifier: "en_US_POSIX")
                    // Try "yyyy-MM-dd"
                    f.dateFormat = "yyyy-MM-dd"
                    if let d = f.date(from: s) { return d }
                    // Try "dd-MM-yyyy" (Aladhan calendar often returns this)
                    f.dateFormat = "dd-MM-yyyy"
                    if let d = f.date(from: s) { return d }
                    return nil
                }

                let clean = { (s: String) in
                    // Aladhan timings often include " (EDT)" or similar
                    return s.components(separatedBy: " ").first ?? s
                }

                // Build a Date object for matching
                let dateObj = parseGregorianDate(gregDateString) ?? Date()

                // Build a Hijri date string like "9 Ramadan 1447"
                let hijriMonthName = day.date.hijri.month.en
                let hijriDay = day.date.hijri.day
                let hijriYear = day.date.hijri.year
                let hijriDateString = "\(hijriDay) \(hijriMonthName) \(hijriYear)"

                let id = "\(day.date.gregorian.date)_\(day.date.hijri.day)"

                return RamadanDay(
                    id: id,
                    date: dateObj,
                    gregorianDate: gregDateString,
                    hijriDate: hijriDateString,
                    imsak: clean(day.timings.Imsak),
                    fajr: clean(day.timings.Fajr),
                    sunrise: clean(day.timings.Sunrise),
                    dhuhr: clean(day.timings.Dhuhr),
                    asr: clean(day.timings.Asr),
                    maghrib: clean(day.timings.Maghrib),
                    isha: clean(day.timings.Isha)
                )
            }

            found.append(contentsOf: ramadanInThisMonth)

            // If we collected enough (usually 29/30), stop
            if found.count >= 29 {
                // sort by actual date ascending
                found.sort(by: { $0.date < $1.date })
                // de-dup just in case
                return Array(Dictionary(grouping: found, by: { $0.id }).values.compactMap(\.first))
                    .sorted(by: { $0.date < $1.date })
            }

            // advance month/year
            month += 1
            if month == 13 { month = 1; year += 1 }
        }

        if found.isEmpty {
            throw NSError(domain: "RamadanVM", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find Ramadan days from the calendar API."])
        }

        found.sort(by: { $0.date < $1.date })
        return found
    }

    private func fetchCalendarMonth(lat: Double, lon: Double, month: Int, year: Int) async throws -> AladhanCalendarResponse {
        // method=2 (ISNA) is common in US. You can change to your preferred calculation method later.
        let urlString =
        "https://api.aladhan.com/v1/calendar?latitude=\(lat)&longitude=\(lon)&method=2&month=\(month)&year=\(year)"

        guard let url = URL(string: urlString) else {
            throw NSError(domain: "RamadanVM", code: 3, userInfo: [NSLocalizedDescriptionKey: "Bad URL."])
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "RamadanVM", code: 4, userInfo: [NSLocalizedDescriptionKey: "Network error fetching calendar (\((resp as? HTTPURLResponse)?.statusCode ?? -1))."])
        }

        do {
            return try JSONDecoder().decode(AladhanCalendarResponse.self, from: data)
        } catch {
            throw NSError(domain: "RamadanVM", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to decode calendar JSON."])
        }
    }

    private func reverseGeocodeCityCountry(for location: CLLocation) async throws -> (String?, String?) {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        let p = placemarks.first
        let city = p?.locality
        let country = p?.country
        return (city, country)
    }

    private func parseGregorianDate(_ s: String) -> Date? {
        // Example: "2026-03-12"
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: s)
    }
}

// MARK: - Aladhan Models (Calendar endpoint)

private struct AladhanCalendarResponse: Decodable {
    let code: Int
    let status: String
    let data: [AladhanCalendarDay]
}

private struct AladhanCalendarDay: Decodable {
    let timings: AladhanTimings
    let date: AladhanDate
}

private struct AladhanTimings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
    let Imsak: String
}

private struct AladhanDate: Decodable {
    let gregorian: AladhanGregorian
    let hijri: AladhanHijri
}

private struct AladhanGregorian: Decodable {
    let date: String   // Often "DD-MM-YYYY"
}

private struct AladhanHijri: Decodable {
    let day: String
    let month: AladhanHijriMonth
    let year: String   // ✅ IMPORTANT: It's STRING in API (e.g. "1447")
}

private struct AladhanHijriMonth: Decodable {
    let number: Int
    let en: String
}
