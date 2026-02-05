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
import AVFoundation

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

    // 🔊 Preview player
    @State private var player: AVAudioPlayer? = nil
    @State private var isPlayingPreview: Bool = false

    private let manager = AdhanNotificationManager.shared
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // ✅ look for adhan.mp3 in bundle
    private var adhanURL: URL? {
        Bundle.main.url(forResource: "adhan", withExtension: "mp3")
    }

    var body: some View {
        NavigationStack {
            Form {

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

                        Toggle(L("تشغيل صوت الأذان", "Play adhan sound"), isOn: binding(\.useSound))
                            .onChange(of: settings.useSound) { _ in
                                persist()
                                if !settings.useSound { stopPreview() }
                            }

                        Text(L("ملاحظة: إذا الهاتف على Silent أو Focus قد لا تسمع صوت.",
                               "Note: Silent/Focus may mute the sound."))
                        .font(.footnote)
                        .foregroundColor(.secondary)

                        // ✅ زر “اسمع الأذان”
                        if settings.useSound {
                            if adhanURL != nil {
                                Button {
                                    isPlayingPreview ? stopPreview() : playPreview()
                                } label: {
                                    HStack {
                                        Image(systemName: isPlayingPreview ? "stop.fill" : "play.fill")
                                        Text(L("اسمع الأذان الآن", "Listen now"))
                                    }
                                }
                            } else {
                                Text(L("⚠️ ملف الصوت غير موجود داخل التطبيق. تأكد adhan.mp3 داخل Target Membership.",
                                       "⚠️ Sound file not found. Ensure adhan.mp3 is in Target Membership."))
                                .font(.footnote)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }

                if settings.isEnabled {
                    Section(header: Text(L("اختر الصلوات", "Choose prayers"))) {
                        Toggle(L("الفجر", "Fajr"), isOn: binding(\.fajr)).onChange(of: settings.fajr) { _ in persist() }
                        Toggle(L("الظهر", "Dhuhr"), isOn: binding(\.dhuhr)).onChange(of: settings.dhuhr) { _ in persist() }
                        Toggle(L("العصر", "Asr"), isOn: binding(\.asr)).onChange(of: settings.asr) { _ in persist() }
                        Toggle(L("المغرب", "Maghrib"), isOn: binding(\.maghrib)).onChange(of: settings.maghrib) { _ in persist() }
                        Toggle(L("العشاء", "Isha"), isOn: binding(\.isha)).onChange(of: settings.isha) { _ in persist() }
                    }
                }

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
                if let m = manager.lastScheduleMessage { message = m }
            }
            .onDisappear { stopPreview() }
        }
    }

    private func binding<T>(_ keyPath: WritableKeyPath<AdhanReminderSettings, T>) -> Binding<T> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { newValue in settings[keyPath: keyPath] = newValue }
        )
    }

    private func persist() { AdhanSettingsStore.save(settings) }

    // MARK: - Preview sound
    private func playPreview() {
        guard let url = adhanURL else { return }
        do {
            // حاول تخليها تشتغل حتى لو الجهاز Silent (قدر الإمكان)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            p.play()
            player = p
            isPlayingPreview = true
        } catch {
            message = L("❌ فشل تشغيل الصوت.", "❌ Failed to play sound.")
            isPlayingPreview = false
        }
    }

    private func stopPreview() {
        player?.stop()
        player = nil
        isPlayingPreview = false
    }

    // MARK: - Schedule
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
