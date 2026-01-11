//
//  RamadanImsakiyahService.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/10/26.
//

import Foundation
import CoreLocation

enum RamadanImsakiyahServiceError: LocalizedError {
    case invalidURL
    case badResponse
    case decodingFailed
    case missingHijriYear

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .badResponse: return "Bad server response."
        case .decodingFailed: return "Failed to decode data."
        case .missingHijriYear: return "Could not detect Hijri year."
        }
    }
}

final class RamadanImsakiyahService {

    // MARK: - Public

    func fetchRamadanDays(location: CLLocation, method: Int = 2) async throws -> [RamadanImsakiyahDay] {
        let hijriYear = try await fetchCurrentHijriYear()
        let days = try await fetchHijriCalendarRamadan(location: location, hijriYear: hijriYear, method: method)
        return days
    }

    // MARK: - Step 1: Get Hijri year from today's date

    private func fetchCurrentHijriYear() async throws -> Int {
        let today = Date()
        let g = GregorianCalendarParts(from: today)

        // Example: https://api.aladhan.com/v1/gToH?date=10-01-2026
        let urlString = "https://api.aladhan.com/v1/gToH?date=\(g.dd)-\(g.MM)-\(g.yyyy)"
        guard let url = URL(string: urlString) else { throw RamadanImsakiyahServiceError.invalidURL }

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw RamadanImsakiyahServiceError.badResponse
        }

        let decoded = try decode(AladhanGtoHResponse.self, from: data)
        guard let yearInt = Int(decoded.data.hijri.year) else {
            throw RamadanImsakiyahServiceError.missingHijriYear
        }
        return yearInt
    }

    // MARK: - Step 2: Fetch Hijri calendar for Ramadan (month 9)

    private func fetchHijriCalendarRamadan(location: CLLocation, hijriYear: Int, method: Int) async throws -> [RamadanImsakiyahDay] {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // https://api.aladhan.com/v1/hijriCalendar?latitude=..&longitude=..&method=2&month=9&year=1447
        var comps = URLComponents(string: "https://api.aladhan.com/v1/hijriCalendar")
        comps?.queryItems = [
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "longitude", value: String(lon)),
            URLQueryItem(name: "method", value: String(method)),
            URLQueryItem(name: "month", value: "9"),
            URLQueryItem(name: "year", value: String(hijriYear))
        ]

        guard let url = comps?.url else { throw RamadanImsakiyahServiceError.invalidURL }

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw RamadanImsakiyahServiceError.badResponse
        }

        let decoded = try decode(AladhanHijriCalendarResponse.self, from: data)

        let mapped: [RamadanImsakiyahDay] = decoded.data.map { day in
            let hijriDay = day.date.hijri.day
            let hijriYearStr = day.date.hijri.year

            // Month names from API are English; we convert Ramadan -> رمضان.
            let monthEn = day.date.hijri.month.en
            let monthAr = (monthEn.lowercased() == "ramadan") ? "رمضان" : monthEn

            let hijriDateAr = "\(hijriDay) \(monthAr) \(hijriYearStr)"
            let hijriDateEn = "\(hijriDay) \(monthEn) \(hijriYearStr)"

            let gregDate = day.date.gregorian.date // often dd-mm-yyyy

            let imsak = cleanTime(day.timings.imsak)
            let fajr = cleanTime(day.timings.fajr)
            let maghrib = cleanTime(day.timings.maghrib)

            return RamadanImsakiyahDay(
                id: "\(hijriYearStr)-09-\(hijriDay)",
                hijriDateAr: hijriDateAr,
                hijriDateEn: hijriDateEn,
                gregorianDate: gregDate,
                imsak: imsak,
                fajr: fajr,
                maghrib: maghrib
            )
        }

        return mapped
    }

    // MARK: - Helpers

    private func cleanTime(_ raw: String) -> String {
        // API returns: "05:12 (EST)" or "05:12"
        let first = raw.split(separator: " ").first.map(String.init) ?? raw
        // Keep HH:mm
        if first.count >= 5 { return String(first.prefix(5)) }
        return first
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw RamadanImsakiyahServiceError.decodingFailed
        }
    }
}

// MARK: - Date parts helper

private struct GregorianCalendarParts {
    let dd: String
    let MM: String
    let yyyy: String

    init(from date: Date) {
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.day, .month, .year], from: date)
        let day = comps.day ?? 1
        let month = comps.month ?? 1
        let year = comps.year ?? 2000

        self.dd = String(format: "%02d", day)
        self.MM = String(format: "%02d", month)
        self.yyyy = String(format: "%04d", year)
    }
}

// MARK: - API Decoding models

private struct AladhanGtoHResponse: Decodable {
    let data: AladhanGtoHData
}

private struct AladhanGtoHData: Decodable {
    let hijri: AladhanHijriDate
}

private struct AladhanHijriDate: Decodable {
    let year: String
}

private struct AladhanHijriCalendarResponse: Decodable {
    let data: [AladhanHijriCalendarDay]
}

private struct AladhanHijriCalendarDay: Decodable {
    let timings: AladhanTimings
    let date: AladhanDateInfo
}

private struct AladhanTimings: Decodable {
    let fajr: String
    let imsak: String
    let maghrib: String

    private enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case imsak = "Imsak"
        case maghrib = "Maghrib"
    }
}

private struct AladhanDateInfo: Decodable {
    let hijri: AladhanHijriInfo
    let gregorian: AladhanGregorianInfo
}

private struct AladhanHijriInfo: Decodable {
    let day: String
    let month: AladhanMonthInfo
    let year: String
}

private struct AladhanMonthInfo: Decodable {
    let en: String
}

private struct AladhanGregorianInfo: Decodable {
    let date: String
}
