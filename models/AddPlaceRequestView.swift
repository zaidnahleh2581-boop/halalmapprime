//
//  AddPlaceRequestView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Category Catalog (String IDs)
struct HMPPlaceCategoryItem: Identifiable, Hashable {
    let id: String            // e.g. "food.restaurant"
    let ar: String
    let en: String
    let requiresApproval: Bool // true for food-related
}

enum HMPPlaceCategoryCatalog {
    static let all: [HMPPlaceCategoryItem] = [

        // ---------- FOOD (requires approval) ----------
        .init(id: "food.restaurant", ar: "مطعم", en: "Restaurant", requiresApproval: true),
        .init(id: "food.grocery", ar: "بقالة / سوبرماركت", en: "Grocery", requiresApproval: true),
        .init(id: "food.market", ar: "ماركت", en: "Market", requiresApproval: true),
        .init(id: "food.food_truck", ar: "فود ترك", en: "Food Truck", requiresApproval: true),
        .init(id: "food.butcher", ar: "ملحمة", en: "Butcher", requiresApproval: true),
        .init(id: "food.bakery", ar: "مخبز", en: "Bakery", requiresApproval: true),
        .init(id: "food.cafe", ar: "كافيه", en: "Cafe", requiresApproval: true),

        // ---------- COMMUNITY / SERVICES (auto approved) ----------
        .init(id: "community.mosque", ar: "مسجد", en: "Mosque", requiresApproval: false),
        .init(id: "community.school", ar: "مدرسة", en: "School", requiresApproval: false),
        .init(id: "community.center", ar: "مركز", en: "Center", requiresApproval: false),

        .init(id: "health.clinic", ar: "عيادة", en: "Clinic", requiresApproval: false),
        .init(id: "health.pharmacy", ar: "صيدلية", en: "Pharmacy", requiresApproval: false),
        .init(id: "legal.lawyer", ar: "مكتب محاماة", en: "Law Office", requiresApproval: false),

        .init(id: "retail.jewelry", ar: "مجوهرات", en: "Jewelry", requiresApproval: false),
        .init(id: "retail.barber", ar: "حلاق", en: "Barber", requiresApproval: false),
        .init(id: "retail.salon", ar: "صالون", en: "Salon", requiresApproval: false),
        .init(id: "retail.phone_store", ar: "محل موبايلات", en: "Phone Store", requiresApproval: false),

        .init(id: "services.hvac", ar: "صيانة / تبريد", en: "HVAC / Refrigeration", requiresApproval: false),
        .init(id: "services.mechanic", ar: "ميكانيك", en: "Mechanic", requiresApproval: false),
        .init(id: "services.other", ar: "خدمات أخرى", en: "Other Services", requiresApproval: false),
    ]

    static func item(for id: String) -> HMPPlaceCategoryItem? {
        all.first { $0.id == id }
    }
}

// MARK: - View
struct AddPlaceRequestView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let onDone: (() -> Void)?

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @State private var businessName = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var phone = ""
    @State private var website = ""

    @State private var selectedCategoryId: String = HMPPlaceCategoryCatalog.all.first?.id ?? "community.center"

    @State private var isSaving = false
    @State private var errorText: String?
    @State private var successText: String?

    var body: some View {
        Form {

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L("إضافة مكان", "Add a Place"))
                        .font(.headline)
                    Text(L(
                        "أماكن الطعام تحتاج موافقة من الإدارة قبل الظهور على الخريطة.",
                        "Food places require admin approval before appearing on the map."
                    ))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section(header: Text(L("معلومات المكان", "Place Info"))) {

                TextField(L("اسم المحل/المكان", "Business / Place name"), text: $businessName)

                Picker(L("التصنيف", "Category"), selection: $selectedCategoryId) {
                    ForEach(HMPPlaceCategoryCatalog.all) { item in
                        Text(lang.isArabic ? item.ar : item.en).tag(item.id)
                    }
                }

                TextField(L("العنوان", "Address"), text: $address)
                TextField(L("المدينة", "City"), text: $city)
                TextField(L("الولاية", "State"), text: $state)

                TextField(L("رقم الهاتف (اختياري)", "Phone (optional)"), text: $phone)
                    .keyboardType(.phonePad)

                TextField(L("الموقع الإلكتروني (اختياري)", "Website (optional)"), text: $website)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if let errorText {
                Section {
                    Text(errorText)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.red)
                }
            }

            if let successText {
                Section {
                    Text(successText)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.green)
                }
            }

            Section {
                Button {
                    save()
                } label: {
                    HStack {
                        if isSaving { ProgressView().padding(.trailing, 6) }
                        Text(isSaving ? L("جاري الحفظ…", "Saving…") : L("إرسال", "Submit"))
                            .font(.headline)
                    }
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle(L("أضف مكان", "Add Place"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) {
                    dismiss()
                    onDone?()
                }
            }
        }
    }

    // MARK: - Save
    private func save() {
        errorText = nil
        successText = nil

        let name = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        let addr = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let s = state.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, !addr.isEmpty, !c.isEmpty, !s.isEmpty else {
            errorText = L("رجاءً املأ الحقول الأساسية (الاسم + العنوان + المدينة + الولاية).",
                          "Please fill required fields (name + address + city + state).")
            return
        }

        // ✅ لازم يكون في مستخدم (Anonymous كفاية)
        guard let uid = Auth.auth().currentUser?.uid else {
            errorText = L("لا يوجد تسجيل دخول (حتى المجهول). تأكد أن التطبيق يعمل anonymous auth.",
                          "No signed-in user (even anonymous). Ensure anonymous auth is enabled.")
            return
        }

        let cat = HMPPlaceCategoryCatalog.item(for: selectedCategoryId)
        let needsApproval = cat?.requiresApproval ?? false
        let approved = !needsApproval

        isSaving = true

        let db = Firestore.firestore()
        let docRef = db.collection("places").document() // auto ID

        let data: [String: Any] = [
            "name": name,
            "address": addr,
            "city": c,
            "state": s,
            "cityState": "\(c), \(s)",
            "categoryId": selectedCategoryId,

            "phone": phone.trimmingCharacters(in: .whitespacesAndNewlines),
            "website": website.trimmingCharacters(in: .whitespacesAndNewlines),

            "ownerUid": uid,

            // ✅ Approval system
            "approvalRequired": needsApproval,
            "isApproved": approved,
            "approvedAt": approved ? FieldValue.serverTimestamp() : NSNull(),

            // created
            "createdAt": FieldValue.serverTimestamp()
        ]

        docRef.setData(data) { err in
            DispatchQueue.main.async {
                self.isSaving = false
                if let err {
                    self.errorText = self.L("فشل الحفظ:", "Save failed:") + " " + err.localizedDescription
                    return
                }

                if approved {
                    self.successText = self.L("تمت الإضافة ✅ (ظهر مباشرة على الخريطة).",
                                              "Submitted ✅ (visible immediately).")
                } else {
                    self.successText = self.L("تم الإرسال ✅ بانتظار موافقة الإدارة.",
                                              "Submitted ✅ pending admin approval.")
                }

                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                self.clearForm()
            }
        }
    }

    private func clearForm() {
        businessName = ""
        address = ""
        city = ""
        state = ""
        phone = ""
        website = ""
        selectedCategoryId = HMPPlaceCategoryCatalog.all.first?.id ?? "community.center"
    }
}
