//
//  RamadanImsakiyahSheet.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/30/26.
//

import SwiftUI
import CoreLocation

struct RamadanImsakiyahSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager

    @StateObject private var vm = RamadanImsakiyahViewModel()

    // ✅ Reminders UI state
    @State private var remindersEnabled: Bool = false
    @State private var minutesBefore: Int = 5

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            List {

                headerCard

                // ✅ Reminders section
                remindersSection

                if let err = vm.errorMessage {
                    Section {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                if vm.days.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L("لا توجد بيانات إمساكية بعد.", "No imsakiyah data yet"))
                                .font(.headline)

                            Text(L("هذا يحدث عندما لا يصلنا موقعك بعد. فعّل الموقع ثم اضغط تحديث.",
                                   "This happens when location isn't available yet. Enable location, then tap Refresh."))
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                            Button {
                                locationManager.requestSingleLocationIfPossible()
                                vm.refresh(from: locationManager.lastLocation)
                            } label: {
                                Label(L("جلب الإمساكية الآن", "Load now"), systemImage: "location.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 6)
                    }
                } else {

                    if let today = todayEntry {
                        Section(header: Text(L("اليوم", "Today"))) {
                            timesGrid(for: today)
                        }
                    }

                    Section(header: Text(L("جدول رمضان كامل", "Full Ramadan schedule"))) {
                        ForEach(vm.days) { d in
                            VStack(alignment: .leading, spacing: 10) {

                                HStack {
                                    Text(d.gregorianDate)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(d.hijriDate)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                VStack(spacing: 8) {
                                    line(L("الإمساك", "Imsak"), d.imsak)
                                    line(L("الفجر", "Fajr"), d.fajr)
                                    line(L("الشروق", "Sunrise"), d.sunrise)
                                    line(L("الظهر", "Dhuhr"), d.dhuhr)
                                    line(L("العصر", "Asr"), d.asr)
                                    line(L("المغرب", "Maghrib"), d.maghrib)
                                    line(L("العشاء", "Isha"), d.isha)
                                }
                                .font(.footnote)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle(L("رمضان والإمساكية", "Ramadan & Imsakiyah"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        locationManager.requestSingleLocationIfPossible()
                        vm.refresh(from: locationManager.lastLocation)
                    } label: {
                        if vm.isLoading { ProgressView().scaleEffect(0.9) }
                        else { Image(systemName: "arrow.clockwise") }
                    }
                    .disabled(vm.isLoading)
                }
            }
            .onAppear {
                locationManager.requestSingleLocationIfPossible()
                vm.loadIfNeeded(from: locationManager.lastLocation)
            }
            .onChange(of: locationManager.lastLocation) { newLoc in
                vm.loadIfNeeded(from: newLoc)
            }
            .alert(L("تنبيهات رمضان", "Ramadan reminders"), isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "moonphase.waning.crescent")
                        .foregroundStyle(.teal)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("إمساكية رمضان", "Ramadan Imsakiyah"))
                            .font(.headline)
                        Text(vm.cityLabel ?? L("حسب موقعك", "Based on your location"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if vm.isLoading { ProgressView().scaleEffect(0.9) }
                }

                if let t = vm.lastUpdated {
                    Text(L("آخر تحديث: \(t.formatted(date: .abbreviated, time: .shortened))",
                           "Last update: \(t.formatted(date: .abbreviated, time: .shortened))"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                Text(L("تظهر الإمساكية حتى لو لم يبدأ رمضان بعد — يتم جلبها بناءً على التقويم الهجري.",
                       "Imsakiyah shows even before Ramadan starts — fetched from Hijri calendar data."))
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - Reminders UI

    private var remindersSection: some View {
        Section {
            Toggle(isOn: $remindersEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("تنبيهات رمضان", "Ramadan reminders"))
                        .font(.headline)
                    Text(L("قبل الإفطار والإمساك بـ \(minutesBefore) دقائق",
                           "\(minutesBefore) minutes before Iftar & Imsak"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .onChange(of: remindersEnabled) { on in
                if on {
                    scheduleRemindersNow()
                } else {
                    // إزالة كل ramadan_*
                    RamadanReminderScheduler.scheduleForToday(
                        imsak: Date().addingTimeInterval(-3600),
                        maghrib: Date().addingTimeInterval(-3600),
                        minutesBefore: 0,
                        isArabic: lang.isArabic
                    )
                    // ↑ trick to clear existing (your scheduler clears prefix ramadan_) ثم لا يضيف لأن fireDate <= Date()
                    alertMessage = L("تم إيقاف تنبيهات اليوم.", "Today's reminders were turned off.")
                    showAlert = true
                }
            }

            Stepper(value: $minutesBefore, in: 1...30) {
                Text(L("قبل الوقت بـ \(minutesBefore) دقائق", "\(minutesBefore) minutes before"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .onChange(of: minutesBefore) { _ in
                if remindersEnabled {
                    scheduleRemindersNow()
                }
            }

            Text(L("ملاحظة: التنبيهات تعمل على هذا الجهاز فقط (Local Notifications).",
                   "Note: reminders are local notifications on this device."))
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private func scheduleRemindersNow() {
        guard let today = todayEntry else {
            remindersEnabled = false
            alertMessage = L("لا يوجد جدول اليوم لتفعيل التنبيهات.", "No 'today' entry to schedule reminders.")
            showAlert = true
            return
        }

        guard let imsakDate = parseTodayTime(today.imsak),
              let maghribDate = parseTodayTime(today.maghrib) else {
            remindersEnabled = false
            alertMessage = L("لم أستطع قراءة وقت الإمساك/المغرب. حاول تحديث الإمساكية.",
                             "Couldn't parse Imsak/Maghrib time. Try refreshing.")
            showAlert = true
            return
        }

        Task {
            let granted = await RamadanReminderScheduler.requestPermissionIfNeeded()
            if !granted {
                remindersEnabled = false
                alertMessage = L("الرجاء تفعيل الإشعارات من إعدادات الآيفون للتطبيق.",
                                 "Please enable notifications for the app in iPhone Settings.")
                showAlert = true
                return
            }

            RamadanReminderScheduler.scheduleForToday(
                imsak: imsakDate,
                maghrib: maghribDate,
                minutesBefore: minutesBefore,
                isArabic: lang.isArabic
            )

            alertMessage = L("تم تفعيل تنبيهات اليوم ✅", "Today's reminders enabled ✅")
            showAlert = true
        }
    }

    // Parses times like "05:12" or "5:12" or "5:12 AM"
    private func parseTodayTime(_ time: String) -> Date? {
        let trimmed = time.trimmingCharacters(in: .whitespacesAndNewlines)
        let cal = Calendar.current
        let base = cal.startOfDay(for: Date())

        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")

        // Try "HH:mm"
        f.dateFormat = "HH:mm"
        if let t = f.date(from: trimmed) {
            let c = cal.dateComponents([.hour, .minute], from: t)
            return cal.date(bySettingHour: c.hour ?? 0, minute: c.minute ?? 0, second: 0, of: base)
        }

        // Try "H:mm"
        f.dateFormat = "H:mm"
        if let t = f.date(from: trimmed) {
            let c = cal.dateComponents([.hour, .minute], from: t)
            return cal.date(bySettingHour: c.hour ?? 0, minute: c.minute ?? 0, second: 0, of: base)
        }

        // Try "h:mm a"
        f.dateFormat = "h:mm a"
        if let t = f.date(from: trimmed) {
            let c = cal.dateComponents([.hour, .minute], from: t)
            return cal.date(bySettingHour: c.hour ?? 0, minute: c.minute ?? 0, second: 0, of: base)
        }

        return nil
    }

    // MARK: - Today helper

    private var todayEntry: RamadanImsakiyahViewModel.RamadanDay? {
        let today = Date()
        return vm.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) } ?? vm.days.first
    }

    // MARK: - UI helpers

    private func timesGrid(for d: RamadanImsakiyahViewModel.RamadanDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                pill(L("الإمساك", "Imsak"), d.imsak)
                pill(L("الفجر", "Fajr"), d.fajr)
                pill(L("المغرب", "Maghrib"), d.maghrib)
            }
            HStack {
                pill(L("الشروق", "Sunrise"), d.sunrise)
                pill(L("الظهر", "Dhuhr"), d.dhuhr)
                pill(L("العصر", "Asr"), d.asr)
            }
            HStack {
                pill(L("العشاء", "Isha"), d.isha)
                Spacer()
            }
        }
        .padding(.vertical, 6)
    }

    private func pill(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func line(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
