//
//  FaithToolsScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2026-02-05.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import CoreLocation

struct FaithToolsScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager
    @EnvironmentObject var router: AppRouter

    @StateObject private var prayerVM = PrayerTimesViewModel()
    @State private var showQiblaInfo: Bool = false
    @State private var showZakatCalculator: Bool = false
    @State private var showAdhanInfo: Bool = false
    @State private var showRamadanInfo: Bool = false

    // ✅ Hadith
    @State private var showHadithOfDay: Bool = false
    @State private var pendingHadithId: String? = nil

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
                                if prayerVM.isLoading { ProgressView().scaleEffect(0.9) }
                                else { Image(systemName: "arrow.clockwise") }
                            }
                            .buttonStyle(.plain)
                            .disabled(prayerVM.isLoading)
                        }

                        if let updated = prayerVM.lastUpdated {
                            Text(L("آخر تحديث: \(formatTime(updated))", "Last updated: \(formatTime(updated))"))
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
                                    Text(formatToAmPm(p.time))
                                        .foregroundColor(.secondary)
                                }
                                .font(.footnote)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 2) Adhan & reminders
                Section(header: Text(L("الأذان والتنبيهات", "Adhan & reminders"))) {
                    Button {
                        showAdhanInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill").foregroundColor(.orange)
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

                // 3) Quran
                Section(header: Text(L("القرآن", "Quran"))) {
                    NavigationLink {
                        QuranHomeScreen()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("القرآن الكريم", "Holy Quran"))
                                    .font(.headline)

                                Text(L("اقرأ السور والآيات كاملة بدون إنترنت.",
                                       "Read full surahs & ayahs offline."))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 4) Hadith
                Section(header: Text(L("الحديث", "Hadith"))) {
                    Button {
                        pendingHadithId = nil
                        showHadithOfDay = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "book.closed.fill").foregroundColor(.purple)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("حديث اليوم", "Hadith of the Day"))
                                    .font(.headline)
                                Text(L("عرض الحديث اليومي داخل التطبيق.",
                                       "Shows daily hadith inside the app."))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 5) Adhkar + Misbaha
                Section(header: Text(L("الأذكار", "Adhkar"))) {

                    NavigationLink {
                        MisbahaScreen()
                            .environmentObject(lang)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.tap")
                                .foregroundStyle(.orange)
                            Text(L("المسبحة", "Misbaha"))
                                .font(.headline)
                        }
                        .padding(.vertical, 4)
                    }

                    NavigationLink {
                        AdhkarHomeScreen()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "hands.sparkles.fill")
                                .foregroundStyle(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("أذكار المسلم", "Daily Adhkar"))
                                    .font(.headline)

                                Text(L("أذكار الصباح والمساء والنوم.",
                                       "Morning, evening, and daily remembrance."))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 6) Ramadan
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

                // 7) Qibla (Soon)
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

                // 8) Zakat
                Section(header: Text(L("زكاة المال", "Zakat calculator"))) {
                    NavigationLink {
                        ZakatCalculatorScreen()
                            .environmentObject(lang)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "percent")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("حاسبة الزكاة", "Zakat calculator"))
                                    .font(.headline)
                                Text(L("احسب زكاتك بسرعة وببساطة.",
                                       "Calculate your zakat quickly and easily."))
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
            .onChange(of: lang.current) { _ in
                prayerVM.refresh(from: locationManager.lastLocation, isArabic: lang.isArabic)
            }

            // ✅ deeplink router
            .onChange(of: router.pendingFaithEntry) { entry in
                guard let entry else { return }
                router.pendingFaithEntry = nil

                switch entry {
                case .imsakiyah:
                    showRamadanInfo = true

                case .hadith(let id):
                    pendingHadithId = id
                    showHadithOfDay = true

                case .prayer:
                    break
                }
            }

            // Sheets
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
            .sheet(isPresented: $showHadithOfDay) {
                HadithOfDaySheet(forcedHadithId: pendingHadithId)
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showQiblaInfo) {
                QiblaInfoSheet().environmentObject(lang)
            }

            // (Zakat sheet intentionally removed for now)
            // .sheet(isPresented: $showZakatCalculator) { ZakatInfoSheet().environmentObject(lang) }
        }
    }

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

    /// Converts "HH:mm" OR "h:mm a" into "h:mm a"
    private func formatToAmPm(_ timeString: String) -> String {
        let trimmed = timeString.trimmingCharacters(in: .whitespacesAndNewlines)

        // if already AM/PM, return it
        if trimmed.lowercased().contains("am") || trimmed.lowercased().contains("pm") {
            return trimmed
        }

        // Try parse "HH:mm"
        let inF = DateFormatter()
        inF.locale = Locale(identifier: "en_US_POSIX")
        inF.dateFormat = "HH:mm"

        let outF = DateFormatter()
        outF.locale = Locale(identifier: "en_US_POSIX")
        outF.dateFormat = "h:mm a"

        if let d = inF.date(from: trimmed) {
            return outF.string(from: d)
        }

        return trimmed
    }
}
