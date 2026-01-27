//
//  FaithToolsScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
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

                // 1) Prayer Times (already working)
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
                                    Text(p.time).foregroundColor(.secondary)
                                }
                                .font(.footnote)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 2) Adhan & reminders (already working)
                Section(header: Text(L("الأذان والتنبيهات", "Adhan & reminders"))) {
                    Button {
                        showAdhanInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill").foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("إعدادات الأذان", "Adhan settings")).font(.headline)
                                Text(L("فعّل تنبيهات الصلاة واختر الصلوات ووقت التذكير.",
                                       "Enable prayer reminders, choose prayers and reminder time."))
                                .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // ✅ 3) Ramadan & Imsakiyah (NOW REAL)
                Section(header: Text(L("رمضان والإمساكية", "Ramadan & Imsakiyah"))) {
                    Button {
                        showRamadanInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "moonphase.waning.crescent").foregroundColor(.teal)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("إمساكية رمضان", "Ramadan Imsakiyah")).font(.headline)
                                Text(L("جدول كامل: إمساك / فجر / إفطار حسب موقعك.",
                                       "Full schedule: Imsak / Fajr / Iftar based on your location."))
                                .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                // ✅ 7) Quran / Hadith / Adhkar (OFFLINE)
                Section(header: Text(L("الإيمان", "Iman"))) {

                    NavigationLink {
                        QuranHomeScreen()
                            .environmentObject(lang)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "book.closed.fill").foregroundColor(.purple)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("القرآن الكريم", "Qur'an")).font(.headline)
                                Text(L("قراءة + ترجمة + بحث + حفظ آخر مكان.", "Read + translation + search + last read."))
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    NavigationLink {
                        HadithHomeScreen()
                            .environmentObject(lang)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "scroll.fill").foregroundColor(.brown)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("حديث اليوم", "Hadith of the Day")).font(.headline)
                                Text(L("حديث محلي يوميًا بدون إنترنت.", "Offline daily hadith."))
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    NavigationLink {
                        AdhkarHomeScreen()
                            .environmentObject(lang)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "leaf.fill").foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("الأذكار", "Adhkar")).font(.headline)
                                Text(L("أذكار بتعداد تلقائي + تصنيفات.", "Categories + built-in counter."))
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                // 4) Qibla
                Section(header: Text(L("اتجاه القبلة", "Qibla direction"))) {
                    Button { showQiblaInfo = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "location.north.line.fill").foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("بوصلة القبلة", "Qibla compass")).font(.headline)
                                Text(L("قريباً بوصلة تفاعلية دقيقة.",
                                       "Soon: an accurate interactive compass."))
                                .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 5) Zakat
                Section(header: Text(L("زكاة المال", "Zakat calculator"))) {
                    Button { showZakatCalculator = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "percent").foregroundColor(.yellow)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("حاسبة الزكاة", "Zakat calculator")).font(.headline)
                                Text(L("قريباً: حساب دقيق وسهل.",
                                       "Soon: easy and accurate calculation."))
                                .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 6) More tools
                Section(header: Text(L("أدوات إضافية", "More tools"))) {
                    Label(L("التقويم الهجري والمواسم", "Hijri calendar & seasons"), systemImage: "calendar")
                        .foregroundColor(.secondary)
                    Label(L("تنبيهات العشر الأواخر", "Last 10 nights reminders"), systemImage: "sparkles")
                        .foregroundColor(.secondary)
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
            .sheet(isPresented: $showQiblaInfo) { QiblaInfoSheet().environmentObject(lang) }
            .sheet(isPresented: $showZakatCalculator) { ZakatInfoSheet().environmentObject(lang) }
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
}

// MARK: - ✅ Ramadan Imsakiyah Sheet (NEW REAL UI)

struct RamadanImsakiyahSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager

    @StateObject private var vm = RamadanImsakiyahViewModel()

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "moonphase.waning.crescent")
                            .foregroundColor(.teal)

                        Text(L("إمساكية رمضان", "Ramadan Imsakiyah"))
                            .font(.headline)

                        Spacer()

                        Button {
                            vm.refresh(from: locationManager.lastLocation)
                        } label: {
                            if vm.isLoading { ProgressView().scaleEffect(0.9) }
                            else { Image(systemName: "arrow.clockwise") }
                        }
                        .buttonStyle(.plain)
                        .disabled(vm.isLoading || locationManager.lastLocation == nil)
                    }

                    Text(vm.cityLabel ?? L("حسب موقعك", "Based on your location"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let updated = vm.lastUpdated {
                        Text(L("آخر تحديث: \(formatTime(updated))", "Last updated: \(formatTime(updated))"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }

                    if locationManager.lastLocation == nil {
                        Text(L("لا يوجد موقع بعد. فعّل الموقع أو افتح الخريطة مرة واحدة.", "No location yet. Enable location or open the Map once."))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                Divider()

                // Content
                if vm.isLoading && vm.days.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(L("جاري تحميل إمساكية رمضان…", "Loading Ramadan schedule…"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 30)
                    Spacer()
                } else {
                    List {
                        Section(header: Text(L("الجدول", "Schedule"))) {
                            ForEach(vm.days) { d in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(d.hijriDate)
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        Text(d.gregorianDate)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    HStack {
                                        Text(L("إمساك", "Imsak"))
                                        Spacer()
                                        Text(d.imsak).foregroundColor(.secondary)
                                    }
                                    .font(.footnote)

                                    HStack {
                                        Text(L("الفجر", "Fajr"))
                                        Spacer()
                                        Text(d.fajr).foregroundColor(.secondary)
                                    }
                                    .font(.footnote)

                                    HStack {
                                        Text(L("الإفطار", "Iftar (Maghrib)"))
                                        Spacer()
                                        Text(d.maghrib).foregroundColor(.secondary)
                                    }
                                    .font(.footnote)
                                }
                                .padding(.vertical, 4)
                            }
                        }
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

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}
