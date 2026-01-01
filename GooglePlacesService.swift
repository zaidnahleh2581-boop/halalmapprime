//
//  GooglePlacesService.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import CoreLocation

/// خدمة الاتصال بـ Google Places
final class GooglePlacesService {

    static let shared = GooglePlacesService()
    private init() {}

    // ضع هنا الـ API Key تبع Google Places
    private let GOOGLE_API_KEY = "AIzaSyAW7eNiYkhbmyrgNzOPU0UwWhytUGTzI_I"

    /// بحث عن أماكن بالقرب من إحداثيات معيّنة
    func searchNearbyHalal(
        coordinate: CLLocationCoordinate2D,
        category: PlaceCategory?,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        let googleType = category?.googleType ?? "restaurant"
        let radius = 5000

        let urlString =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
        "?location=\(coordinate.latitude),\(coordinate.longitude)" +
        "&radius=\(radius)" +
        "&type=\(googleType)" +
        "&key=\(GOOGLE_API_KEY)"

        guard let url = URL(string: urlString) else {
            completion(.success([]))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.success([])) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)

                let places: [Place] = decoded.results.compactMap { result -> Place? in
                    guard
                        let lat = result.geometry?.location?.lat,
                        let lng = result.geometry?.location?.lng
                    else { return nil }

                    return Place(
                        id: result.place_id ?? UUID().uuidString,
                        name: result.name ?? "Unknown",
                        address: result.vicinity ?? "",
                        cityState: "",
                        latitude: lat,
                        longitude: lng,
                        category: category ?? .restaurant,
                        rating: result.rating ?? 0,
                        reviewCount: result.user_ratings_total ?? 0,
                        deliveryAvailable: false,
                        isCertified: false,

                        // ✅ Contact
                        phone: nil,
                        website: nil,

                        // ✅ Ads (عندك String مش Enum)
                        adStatus: "none",
                        adPlan: "none",
                        adPriority: 0,
                        startAt: nil,
                        endAt: nil,
                        isAdActive: false
                    )
                }

                DispatchQueue.main.async {
                    completion(.success(places))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

        }.resume()
    }
}
