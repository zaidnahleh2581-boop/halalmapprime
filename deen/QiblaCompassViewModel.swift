//
//  QiblaCompassViewModel.swift
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
final class QiblaCompassViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Published
    @Published private(set) var headingDegrees: Double? = nil     // 0...360 (true heading if available)
    @Published private(set) var qiblaBearing: Double? = nil       // 0...360
    @Published private(set) var qiblaOffset: Double? = nil        // -180...180 (turn amount)
    @Published private(set) var statusText: String = "—"

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    // Kaaba coordinates
    private let kaabaLat: Double = 21.4225
    private let kaabaLon: Double = 39.8262

    override init() {
        super.init()
        manager.delegate = self
        manager.headingFilter = kCLHeadingFilterNone
    }

    // MARK: - Public

    func start(using location: CLLocation?) {
        lastLocation = location
        updateBearingIfPossible()

        // لازم Location authorization (WhenInUse/Always)
        let auth = manager.authorizationStatus
        if auth == .authorizedWhenInUse || auth == .authorizedAlways {
            beginHeadingUpdates()
            statusText = "Calibrating…"
        } else if auth == .notDetermined {
            // ما نطلب إذن هون عشان انت عندك شاشة إذن ومكان واحد
            statusText = "Location permission needed"
        } else {
            statusText = "Location disabled"
        }
    }

    func updateLocation(_ location: CLLocation?) {
        lastLocation = location
        updateBearingIfPossible()
    }

    func stop() {
        manager.stopUpdatingHeading()
    }

    // MARK: - Heading updates

    private func beginHeadingUpdates() {
        guard CLLocationManager.headingAvailable() else {
            statusText = "Heading not available"
            return
        }
        manager.startUpdatingHeading()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let auth = manager.authorizationStatus
        if auth == .authorizedWhenInUse || auth == .authorizedAlways {
            beginHeadingUpdates()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // trueHeading أفضل، بس ممكن يرجع -1
        let h = (newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading
        headingDegrees = normalize360(h)

        updateOffsetIfPossible()

        // iOS أحياناً يطلب معايرة
        if newHeading.headingAccuracy < 0 {
            statusText = "Move phone in a figure-8"
        } else {
            statusText = "Ready"
        }
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        true
    }

    // MARK: - Qibla math

    private func updateBearingIfPossible() {
        guard let loc = lastLocation else {
            qiblaBearing = nil
            qiblaOffset = nil
            return
        }
        qiblaBearing = bearingToKaaba(from: loc.coordinate)
        updateOffsetIfPossible()
    }

    private func updateOffsetIfPossible() {
        guard let bearing = qiblaBearing, let heading = headingDegrees else {
            qiblaOffset = nil
            return
        }

        // الفرق بين اتجاه القبلة واتجاه الجهاز
        var diff = bearing - heading
        diff = normalize180(diff)
        qiblaOffset = diff
    }

    private func bearingToKaaba(from user: CLLocationCoordinate2D) -> Double {
        let lat1 = deg2rad(user.latitude)
        let lon1 = deg2rad(user.longitude)
        let lat2 = deg2rad(kaabaLat)
        let lon2 = deg2rad(kaabaLon)

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let brng = atan2(y, x) // radians
        return normalize360(rad2deg(brng))
    }

    // MARK: - Helpers

    private func deg2rad(_ d: Double) -> Double { d * .pi / 180 }
    private func rad2deg(_ r: Double) -> Double { r * 180 / .pi }

    private func normalize360(_ v: Double) -> Double {
        var x = v.truncatingRemainder(dividingBy: 360)
        if x < 0 { x += 360 }
        return x
    }

    private func normalize180(_ v: Double) -> Double {
        var x = v.truncatingRemainder(dividingBy: 360)
        if x > 180 { x -= 360 }
        if x < -180 { x += 360 }
        return x
    }
}
