//
//  MisbahaScreen.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import SwiftUI
import UIKit
import Combine

final class MisbahaStore: ObservableObject {

    @Published var count: Int = 0
    @Published var target: Int = 33

    @Published var phraseAR: String = "سبحان الله"
    @Published var phraseEN: String = "SubhanAllah"

    private let key = "misbaha_v1"

    init() { load() }

    func inc() {
        count += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        save()
    }

    func reset() {
        count = 0
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        save()
    }

    func setTarget(_ n: Int) {
        target = n
        save()
    }

    func setPhrase(ar: String, en: String) {
        phraseAR = ar
        phraseEN = en
        save()
    }

    private func save() {
        let obj: [String: Any] = [
            "count": count,
            "target": target,
            "phraseAR": phraseAR,
            "phraseEN": phraseEN
        ]
        UserDefaults.standard.set(obj, forKey: key)
    }

    private func load() {
        guard let obj = UserDefaults.standard.dictionary(forKey: key) else { return }
        count = obj["count"] as? Int ?? 0
        target = obj["target"] as? Int ?? 33
        phraseAR = obj["phraseAR"] as? String ?? "سبحان الله"
        phraseEN = obj["phraseEN"] as? String ?? "SubhanAllah"
    }
}

struct MisbahaScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @StateObject private var store = MisbahaStore()
    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {

                VStack(spacing: 8) {
                    Text(L("المسبحة", "Misbaha"))
                        .font(.largeTitle).bold()

                    Text(lang.isArabic ? store.phraseAR : store.phraseEN)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 10)

                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.ultraThinMaterial)

                    VStack(spacing: 12) {
                        Text("\(store.count)")
                            .font(.system(size: 64, weight: .bold))

                        Text(L("الهدف", "Target") + ": \(store.target)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        ProgressView(value: Double(store.count % max(store.target, 1)),
                                     total: Double(max(store.target, 1)))
                    }
                    .padding(20)
                }
                .frame(height: 220)
                .padding(.horizontal)

                Button {
                    store.inc()
                } label: {
                    Text(L("تسبيح", "Tap to Count"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)

                HStack(spacing: 12) {

                    Button {
                        store.reset()
                    } label: {
                        Label(L("تصفير", "Reset"), systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.red.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        showPicker = true
                    } label: {
                        Label(L("اختيار ذكر", "Pick Dhikr"), systemImage: "slider.horizontal.3")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.gray.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 10) {
                    targetButton(33)
                    targetButton(99)
                    targetButton(100)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom, 10)
            .navigationTitle(L("المسبحة", "Misbaha"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPicker) {
                MisbahaPicker(
                    onPick: { ar, en in
                        store.setPhrase(ar: ar, en: en)
                        showPicker = false
                    }
                )
                .environmentObject(lang)
            }
        }
    }

    private func targetButton(_ n: Int) -> some View {
        Button {
            store.setTarget(n)
        } label: {
            Text("\(n)")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(store.target == n ? .blue.opacity(0.25) : .gray.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct MisbahaPicker: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    let onPick: (_ ar: String, _ en: String) -> Void

    private let presets: [(ar: String, en: String)] = [
        ("سبحان الله", "SubhanAllah"),
        ("الحمد لله", "Alhamdulillah"),
        ("الله أكبر", "Allahu Akbar"),
        ("لا إله إلا الله", "La ilaha illallah"),
        ("أستغفر الله", "Astaghfirullah"),
        ("لا حول ولا قوة إلا بالله", "La hawla wa la quwwata illa billah")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(L("اختر الذكر للمسبحة:", "Pick a dhikr for the misbaha:"))
                        .foregroundStyle(.secondary)
                }

                ForEach(presets.indices, id: \.self) { i in
                    let p = presets[i]
                    Button {
                        onPick(p.ar, p.en)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(lang.isArabic ? p.ar : p.en).font(.headline)
                            Text(lang.isArabic ? p.en : p.ar).font(.footnote).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle(L("اختيار ذكر", "Pick Dhikr"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
