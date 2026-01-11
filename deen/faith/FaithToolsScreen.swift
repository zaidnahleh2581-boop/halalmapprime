//
//  FaithToolsScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2026-01-11.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import CoreLocation

struct FaithToolsScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager

    @StateObject private var prayerVM = PrayerTimesViewModel()

    @State private var showQiblaInfo: Bool = false
    @State private var showZakatCalculator: Bool = false
    @State private var showAdhanInfo: Bool = false
    @State private var showRamadanInfo: Bool = false

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            List {

                // 1) Prayer Times
                Section(header: Text(L("أوقات الصلاة", "Prayer times"))) {
                    VStack(alignment: .leading, spacing: 10) {

                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)

                            Text(prayerVM.cityLabel ?? L("حسب موقعك", "Based on your location"))
                                .font(.subheadline.weight(.semibold))

                            Spacer()

                            Button {
                                prayerVM.refresh(from: locationManager.lastLocation, isArabic: lang.isArabic)
                            } label: {
                                if prayerVM.isLoading {
                                    ProgressView().scaleEffect(0.9)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(prayerVM.isLoading)
                        }

                        if let updated = prayerVM.lastUpdated {
                            Text(L("آخر تحديث: \(formatTime(updated))",
                                   "Last updated: \(formatTime(updated))"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        let data = prayerVM.prayerTimes ?? samplePrayerTimes

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(data, id: \.name) { p in
                                HStack {
                                    Text(p.name)
                                    Spacer()
                                    Text(p.time)
                                        .foregroundColor(.secondary)
                                }
                                .font(.footnote)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 2) Adhan
                Section(header: Text(L("الأذان والتنبيهات", "Adhan & reminders"))) {
                    Button {
                        showAdhanInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("إعدادات الأذان", "Adhan settings"))
                                    .font(.headline)

                                Text(L("فعّل تنبيهات الصلاة واختر الصلوات ووقت التذكير.",
                                       "Enable prayer reminders, choose prayers and reminder time."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 3) Ramadan
                Section(header: Text(L("رمضان والإمساكية", "Ramadan & Imsakiyah"))) {
                    Button {
                        showRamadanInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "moonphase.waning.crescent")
                                .foregroundColor(.teal)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("إمساكية رمضان", "Ramadan Imsakiyah"))
                                    .font(.headline)

                                Text(L("جدول كامل: إمساك / فجر / إفطار حسب موقعك.",
                                       "Full schedule: Imsak / Fajr / Iftar based on your location."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 4) Qibla
                Section(header: Text(L("اتجاه القبلة", "Qibla direction"))) {
                    Button { showQiblaInfo = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "location.north.line.fill")
                                .foregroundColor(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("بوصلة القبلة", "Qibla compass"))
                                    .font(.headline)

                                Text(L("قريباً بوصلة تفاعلية دقيقة.",
                                       "Soon: an accurate interactive compass."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 5) Zakat
                Section(header: Text(L("زكاة المال", "Zakat calculator"))) {
                    Button { showZakatCalculator = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "percent")
                                .foregroundColor(.yellow)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("حاسبة الزكاة", "Zakat calculator"))
                                    .font(.headline)

                                Text(L("قريباً: حساب دقيق وسهل.",
                                       "Soon: easy and accurate calculation."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(L("أدوات المسلم", "Faith tools"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestWhenInUseAuthorizationIfNeeded()
                locationManager.requestSingleLocationIfPossible()
                prayerVM.loadIfPossible(from: locationManager.lastLocation, isArabic: lang.isArabic)
            }
            .onChange(of: locationManager.lastLocation) { newLoc in
                prayerVM.loadIfPossible(from: newLoc, isArabic: lang.isArabic)
            }
            .sheet(isPresented: $showAdhanInfo) {
                AdhanSettingsSheet()
                    .environmentObject(lang)
                    .environmentObject(locationManager)
            }
            .sheet(isPresented: $showRamadanInfo) {
                RamadanImsakiyahSheet()
                    .environmentObject(lang)
                    .environmentObject(locationManager)
            }
            .sheet(isPresented: $showQiblaInfo) {
                QiblaInfoSheet().environmentObject(lang)
            }
            .sheet(isPresented: $showZakatCalculator) {
                ZakatInfoSheet().environmentObject(lang)
            }
        }
    }

    // MARK: - Sample data

    private var samplePrayerTimes: [PrayerTime] {
        [
            PrayerTime(name: L("الفجر", "Fajr"), time: "05:30"),
            PrayerTime(name: L("الشروق", "Sunrise"), time: "07:00"),
            PrayerTime(name: L("الظهر", "Dhuhr"), time: "12:10"),
            PrayerTime(name: L("العصر", "Asr"), time: "15:30"),
            PrayerTime(name: L("المغرب", "Maghrib"), time: "16:45"),
            PrayerTime(name: L("العشاء", "Isha"), time: "18:10")
        ]
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

// MARK: - Ramadan Imsakiyah Sheet

struct RamadanImsakiyahSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager
    @StateObject private var vm = RamadanImsakiyahViewModel()

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    /// ✅ التحويل من 24 ساعة إلى AM/PM
    private func toAmPm(_ hhmm: String) -> String {
        let inF = DateFormatter()
        inF.locale = Locale(identifier: "en_US_POSIX")
        inF.dateFormat = "HH:mm"

        let outF = DateFormatter()
        outF.locale = Locale(identifier: lang.isArabic ? "ar" : "en_US_POSIX")
        outF.dateFormat = "h:mm a"

        guard let date = inF.date(from: hhmm) else { return hhmm }
        return outF.string(from: date)
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(L("الجدول", "Schedule"))) {
                    ForEach(vm.days) { d in
                        VStack(alignment: .leading, spacing: 6) {

                            HStack {
                                Text(lang.isArabic ? d.hijriDateAr : d.hijriDateEn)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(d.gregorianDate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Text(L("إمساك", "Imsak"))
                                Spacer()
                                Text(toAmPm(d.imsak))
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Text(L("الفجر", "Fajr"))
                                Spacer()
                                Text(toAmPm(d.fajr))
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Text(L("الإفطار", "Iftar (Maghrib)"))
                                Spacer()
                                Text(toAmPm(d.maghrib))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(L("رمضان", "Ramadan"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestWhenInUseAuthorizationIfNeeded()
                locationManager.requestSingleLocationIfPossible()
                vm.loadIfNeeded(from: locationManager.lastLocation)
            }
            .onChange(of: locationManager.lastLocation) { newLoc in
                vm.loadIfNeeded(from: newLoc)
            }
        }
    }
}
