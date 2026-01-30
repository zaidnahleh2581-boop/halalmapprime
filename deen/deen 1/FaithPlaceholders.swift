//
//  FaithPlaceholders.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import CoreLocation

// ✅ ملاحظة:
// تم إزالة AdhanSettingsSheet من هذا الملف لتفادي تكرار التعريف.
// شاشة إعدادات الأذان الآن موجودة فقط في: AdhanSettingsSheet.swift

// MARK: - ✅ Qibla Compass (REAL)

struct QiblaInfoSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager

    @StateObject private var vm = QiblaCompassViewModel()

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                VStack(spacing: 6) {
                    Text(L("بوصلة القبلة", "Qibla Compass"))
                        .font(.title2.bold())

                    Text(vm.statusText)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                ZStack {
                    Circle()
                        .strokeBorder(Color(.systemGray4), lineWidth: 2)
                        .frame(width: 260, height: 260)

                    Text("N")
                        .font(.headline)
                        .offset(y: -120)

                    Image(systemName: "location.north.fill")
                        .font(.system(size: 56, weight: .bold))
                        .rotationEffect(.degrees(vm.qiblaOffset ?? 0))
                        .animation(.easeInOut(duration: 0.12), value: vm.qiblaOffset ?? 0)

                    Circle()
                        .fill(Color(.systemGray))
                        .frame(width: 8, height: 8)
                }

                VStack(spacing: 8) {
                    HStack {
                        Text(L("اتجاه القبلة", "Qibla bearing"))
                        Spacer()
                        Text(formatDeg(vm.qiblaBearing))
                            .foregroundColor(.secondary)
                    }
                    .font(.footnote)

                    HStack {
                        Text(L("اتجاه الهاتف", "Phone heading"))
                        Spacer()
                        Text(formatDeg(vm.headingDegrees))
                            .foregroundColor(.secondary)
                    }
                    .font(.footnote)

                    HStack {
                        Text(L("لف باتجاه", "Turn"))
                        Spacer()
                        Text(turnText(vm.qiblaOffset))
                            .foregroundColor(.secondary)
                    }
                    .font(.footnote)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 6) {
                    Text(L("ملاحظات:", "Notes:"))
                        .font(.footnote.bold())

                    Text(L("• إذا ظهرت المعايرة، حرّك الهاتف حركة رقم 8.", "• If calibration appears, move the phone in a figure-8."))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(L("• يجب تفعيل Location للتطبيق.", "• Location must be enabled for the app."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 10)
            .navigationTitle(L("القبلة", "Qibla"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestWhenInUseAuthorizationIfNeeded()
                locationManager.requestSingleLocationIfPossible()
                vm.start(using: locationManager.lastLocation)
            }
            .onChange(of: locationManager.lastLocation) { newLoc in
                vm.updateLocation(newLoc)
            }
            .onDisappear {
                vm.stop()
            }
        }
    }

    private func formatDeg(_ v: Double?) -> String {
        guard let v else { return "—" }
        return String(format: "%.0f°", v)
    }

    private func turnText(_ v: Double?) -> String {
        guard let v else { return "—" }
        if abs(v) < 4 { return L("ممتاز ✅", "Perfect ✅") }
        if v > 0 {
            return lang.isArabic ? "يمين \(Int(abs(v)))°" : "Right \(Int(abs(v)))°"
        } else {
            return lang.isArabic ? "يسار \(Int(abs(v)))°" : "Left \(Int(abs(v)))°"
        }
    }
}

// MARK: - Zakat (Placeholder)

struct ZakatInfoSheet: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "percent")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)

                Text(L("حاسبة الزكاة", "Zakat Calculator"))
                    .font(.title2.bold())

                Text(
                    L(
                        "سيتم إضافة حاسبة زكاة كاملة ودقيقة قريبًا.",
                        "A full and accurate zakat calculator will be added soon."
                    )
                )
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle(L("الزكاة", "Zakat"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
