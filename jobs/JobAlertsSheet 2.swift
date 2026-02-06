//
//  JobAlertsSheet.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-29.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct JobAlertsSheet: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @StateObject private var vm = JobAlertsVM()

    var body: some View {
        NavigationStack {
            Form {

                Section {
                    Toggle(isOn: $vm.enabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("تفعيل تنبيهات الوظائف", "Enable Job Alerts"))
                            Text(L("يوصلك إشعار عند نزول وظيفة جديدة حسب إعداداتك.", "Get notified when new job ads match your settings."))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(header: Text(L("المدن", "Cities"))) {
                    TextField(L("مثال: Brooklyn, Staten Island", "e.g. Brooklyn, Staten Island"), text: $vm.citiesText)
                        .textInputAutocapitalization(.words)

                    Text(L("افصل بين المدن بفاصلة.", "Separate cities with commas."))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text(L("نوع الإعلان", "Ad Type"))) {
                    Toggle(isOn: $vm.wantHiring) {
                        Text(L("أبحث عن موظف", "Hiring"))
                    }
                    Toggle(isOn: $vm.wantLooking) {
                        Text(L("أبحث عن عمل", "Looking for Job"))
                    }
                }

                Section(header: Text(L("تصنيفات الوظائف (اختياري)", "Job Categories (optional)"))) {
                    TextField(L("مثال: HVAC Technician, Barber", "e.g. HVAC Technician, Barber"), text: $vm.categoriesText)
                        .textInputAutocapitalization(.words)

                    Text(L("إذا تركته فاضي: توصلك كل الوظائف حسب المدينة والنوع.", "Leave empty to receive all matching jobs by city/type."))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        Task { await vm.enableNotificationsAndSave() }
                    } label: {
                        HStack {
                            Spacer()
                            if vm.isSaving { ProgressView() }
                            Text(L("حفظ", "Save"))
                            Spacer()
                        }
                    }
                    .disabled(vm.isSaving)

                    if let msg = vm.statusMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(L("تنبيهات الوظائف", "Job Alerts"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("إغلاق", "Close")) { dismiss() }
                }
            }
            .onAppear {
                Task { await vm.load() }
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
final class JobAlertsVM: ObservableObject {
    

    @Published var enabled: Bool = false
    @Published var citiesText: String = ""
    @Published var wantHiring: Bool = true
    @Published var wantLooking: Bool = true
    @Published var categoriesText: String = ""

    @Published var isSaving: Bool = false
    @Published var statusMessage: String?

    private let db = Firestore.firestore()

    private func ensureAnonAuth() async throws {
        if Auth.auth().currentUser != nil { return }
        _ = try await Auth.auth().signInAnonymously()
    }

    func load() async {
        do {
            try await ensureAnonAuth()
            guard let uid = Auth.auth().currentUser?.uid else { return }

            let ref = db.collection("jobAlertSubs").document(uid)
            let snap = try await ref.getDocument()
            guard let data = snap.data() else { return }

            enabled = data["enabled"] as? Bool ?? false

            let cities = data["cities"] as? [String] ?? []
            citiesText = cities.joined(separator: ", ")

            let types = data["types"] as? [String] ?? []
            wantHiring = types.contains("hiring")
            wantLooking = types.contains("lookingForJob")

            let cats = data["categories"] as? [String] ?? []
            categoriesText = cats.joined(separator: ", ")

        } catch {
            print("Load job alerts failed: \(error)")
        }
    }

    func enableNotificationsAndSave() async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await ensureAnonAuth()

            // ✅ اطلب إذن الإشعارات + خزّن التوكن
            await PushManager.shared.requestPermissionAndRegister()

            guard let uid = Auth.auth().currentUser?.uid else { return }

            let cities = citiesText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            var types: [String] = []
            if wantHiring { types.append("hiring") }
            if wantLooking { types.append("lookingForJob") }
            if types.isEmpty { types = ["hiring","lookingForJob"] }

            let categories = categoriesText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            let ref = db.collection("jobAlertSubs").document(uid)
            try await ref.setData([
                "enabled": enabled,
                "cities": cities,
                "types": types,
                "categories": categories,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)

            statusMessage = "✅ Saved"

        } catch {
            statusMessage = "❌ Failed to save"
            print("Save job alerts failed: \(error.localizedDescription)")
        }
    }
}

