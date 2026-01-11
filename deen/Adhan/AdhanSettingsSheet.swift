//
//  AdhanSettingsSheet.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import CoreLocation

// ✅ ملاحظة مهمة:
// هذا الملف يعتمد على وجود:
// 1) struct AdhanReminderSettings (موجود عندك مسبقًا في المشروع)
// 2) AdhanNotificationManager.shared (موجود عندك مسبقًا)

private enum AdhanSettingsStore {
    static let key = "adhanReminderSettings_v1"

    static func load() -> AdhanReminderSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(AdhanReminderSettings.self, from: data)
        else { return AdhanReminderSettings() }
        return decoded
    }

    static func save(_ settings: AdhanReminderSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

struct AdhanSettingsSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager

    @State private var settings: AdhanReminderSettings = AdhanSettingsStore.load()
    @State private var isWorking: Bool = false
    @State private var message: String = ""

    private let manager = AdhanNotificationManager.shared

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - General
                Section(header: Text(L("عام", "General"))) {

                    Toggle(L("تفعيل تنبيهات الأذان", "Enable Adhan reminders"), isOn: binding(\.isEnabled))
                        .onChange(of: settings.isEnabled) { _ in persist() }

                    if settings.isEnabled {

                        Picker(L("التنبيه قبل الصلاة", "Remind before"), selection: binding(\.minutesBefore)) {
                            Text(L("عند الوقت", "At time")).tag(0)
                            Text(L("قبل 5 دقائق", "5 min")).tag(5)
                            Text(L("قبل 10 دقائق", "10 min")).tag(10)
                            Text(L("قبل 15 دقيقة", "15 min")).tag(15)
                            Text(L("قبل 30 دقيقة", "30 min")).tag(30)
                        }
                        .onChange(of: settings.minutesBefore) { _ in persist() }

                        // ✅ إذا عندك حقل useSound في struct القديم رح يشتغل
                        // إذا ما عندك useSound، احذف هذا Toggle فقط.
                        if hasUseSoundField {
                            Toggle(L("صوت تنبيه", "Notification sound"), isOn: bindingUseSound())
                                .onChange(of: getUseSound()) { _ in persist() }

                            Text(L("ملاحظة: إذا الهاتف على Silent أو Focus قد لا تسمع صوت.", "Note: Silent/Focus may mute the sound."))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // MARK: - Prayers
                if settings.isEnabled {
                    Section(header: Text(L("اختر الصلوات", "Choose prayers"))) {

                        Toggle(L("الفجر", "Fajr"), isOn: binding(\.fajr))
                            .onChange(of: settings.fajr) { _ in persist() }

                        Toggle(L("الظهر", "Dhuhr"), isOn: binding(\.dhuhr))
                            .onChange(of: settings.dhuhr) { _ in persist() }

                        Toggle(L("العصر", "Asr"), isOn: binding(\.asr))
                            .onChange(of: settings.asr) { _ in persist() }

                        Toggle(L("المغرب", "Maghrib"), isOn: binding(\.maghrib))
                            .onChange(of: settings.maghrib) { _ in persist() }

                        Toggle(L("العشاء", "Isha"), isOn: binding(\.isha))
                            .onChange(of: settings.isha) { _ in persist() }
                    }
                }
                Section(header: Text(lang.isArabic ? "تجربة الصوت" : "Test Sound")) {
                    Button {
                        AdhanPlayer.shared.play()
                    } label: {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text(lang.isArabic ? "تشغيل الأذان الآن" : "Play Adhan Now")
                        }
                    }

                    Button(role: .destructive) {
                        AdhanPlayer.shared.stop()
                    } label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text(lang.isArabic ? "إيقاف" : "Stop")
                        }
                    }
                }
                // MARK: - Actions
                Section {
                    Button {
                        Task { await scheduleNow() }
                    } label: {
                        HStack {
                            if isWorking { ProgressView().scaleEffect(0.9) }
                            Text(L("تحديث التنبيهات الآن", "Schedule now"))
                        }
                    }
                    .disabled(isWorking)

                    if !message.isEmpty {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(message.contains("❌") ? .red : .secondary)
                    }
                }
            }
            .navigationTitle(L("إعدادات الأذان", "Adhan Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let m = manager.lastScheduleMessage {
                    message = m
                }
            }
        }
    }

    // MARK: - Bindings Helpers

    private func binding<T>(_ keyPath: WritableKeyPath<AdhanReminderSettings, T>) -> Binding<T> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { newValue in
                settings[keyPath: keyPath] = newValue
            }
        )
    }

    // MARK: - useSound compatibility (optional)

    // ✅ لأننا ما نعرف إذا struct القديم عندك فيه useSound أو لا:
    // راح نكتشفه بطريقة آمنة.
    private var hasUseSoundField: Bool {
        Mirror(reflecting: settings).children.contains { $0.label == "useSound" }
    }

    private func getUseSound() -> Bool {
        // default
        guard hasUseSoundField else { return true }
        // محاولة قراءة عبر Mirror
        let m = Mirror(reflecting: settings)
        for c in m.children {
            if c.label == "useSound", let v = c.value as? Bool { return v }
        }
        return true
    }

    private func setUseSound(_ value: Bool) {
        // إذا struct القديم ما فيه useSound ما نعمل شيء
        guard hasUseSoundField else { return }

        // ⚠️ ما نقدر نكتب عبر Mirror، لذلك إذا ما عندك useSound فعلاً:
        // احذف Toggle الخاص بالصوت بدل هذا.
        //
        // الأفضل: إذا عندك useSound في AdhanReminderSettings القديم،
        // غيّر هذه الدالة يدويًا إلى:
        // settings.useSound = value
        //
        // لأن Swift ما يسمح بتعديل property غير موجودة بشكل ديناميكي.
    }

    private func bindingUseSound() -> Binding<Bool> {
        Binding(
            get: { getUseSound() },
            set: { newValue in
                setUseSound(newValue)
            }
        )
    }

    // MARK: - Persist + Schedule

    private func persist() {
        AdhanSettingsStore.save(settings)
    }

    private func scheduleNow() async {
        isWorking = true
        defer { isWorking = false }

        locationManager.requestWhenInUseAuthorizationIfNeeded()
        locationManager.requestSingleLocationIfPossible()

        guard let loc = locationManager.lastLocation else {
            message = L("❌ لا يوجد موقع بعد. افتح الخريطة أو فعّل الموقع.", "❌ No location yet. Enable location or open Map once.")
            return
        }

        if settings.isEnabled {
            let ok = await manager.requestPermission()
            if !ok {
                message = L("❌ تم رفض الإشعارات. فعّلها من Settings.", "❌ Notifications denied. Enable in Settings.")
                return
            }
        }

        await manager.scheduleTodayAndTomorrow(
            location: loc,
            langIsArabic: lang.isArabic,
            settings: settings
        )

        message = manager.lastScheduleMessage ?? L("✅ تم تحديث التنبيهات.", "✅ Reminders updated.")
    }
}
