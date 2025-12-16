//
//  FreeAdFormView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import SwiftUI
import PhotosUI

struct FreeAdFormView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // ✅ Store (Singleton)
    @ObservedObject private var adsStore = AdsStore.shared

    // MARK: - Form fields
    @State private var businessName: String = ""
    @State private var ownerName: String = ""
    @State private var phone: String = ""
    @State private var addressLine: String = ""
    @State private var city: String = ""
    @State private var state: String = ""

    @State private var businessType: Ad.BusinessType = .restaurant
    @State private var template: Ad.CopyTemplate = .simple

    // Optional placeId (لو عندك Place.id لاحقاً)
    @State private var placeIdOptional: String = ""

    // Photos
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var pickedImages: [UIImage] = []

    @State private var showSavedAlert = false
    @State private var errorMessage: String? = nil

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text(L("بيانات المحل", "Business info"))) {
                    TextField(L("اسم المحل", "Business name"), text: $businessName)
                    TextField(L("اسم صاحب المحل", "Owner name"), text: $ownerName)
                    TextField(L("رقم الهاتف", "Phone number"), text: $phone)
                        .keyboardType(.phonePad)

                    TextField(L("العنوان", "Address"), text: $addressLine)
                    HStack {
                        TextField(L("المدينة", "City"), text: $city)
                        TextField(L("الولاية", "State"), text: $state)
                            .frame(width: 80)
                            .textInputAutocapitalization(.characters)
                    }
                }

                Section(header: Text(L("نوع النشاط", "Business type"))) {
                    Picker(L("اختر النوع", "Select type"), selection: $businessType) {
                        ForEach(Ad.BusinessType.allCases) { t in
                            Text(lang.isArabic ? t.titleAR : t.titleEN).tag(t)
                        }
                    }
                }

                Section(header: Text(L("قالب الإعلان", "Ad template"))) {
                    Picker(L("اختر قالب", "Choose template"), selection: $template) {
                        ForEach(Ad.CopyTemplate.allCases) { t in
                            Text(lang.isArabic ? t.titleAR : t.titleEN).tag(t)
                        }
                    }

                    // Preview
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L("معاينة النص", "Copy preview"))
                            .font(.footnote.bold())
                        Text(previewCopy())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                Section(header: Text(L("صور الإعلان (1–3)", "Ad images (1–3)"))) {

                    PhotosPicker(
                        selection: $pickedItems,
                        maxSelectionCount: 3,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text(L("اختر صور", "Pick photos"))
                            Spacer()
                        }
                    }
                    .onChange(of: pickedItems) { newItems in
                        Task { await loadImages(from: newItems) }
                    }

                    if pickedImages.isEmpty {
                        Text(L("لم يتم اختيار صور بعد.", "No images selected yet."))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(pickedImages.enumerated()), id: \.offset) { _, img in
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 90)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section(header: Text(L("ربط الإعلان (اختياري)", "Linking (optional)"))) {
                    TextField(L("Place ID (اختياري)", "Place ID (optional)"), text: $placeIdOptional)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text(L(
                        "إذا عندك Place.id للإضافة الموجودة، الإعلان عند الضغط يفتح تفاصيل المحل. إذا تركته فارغ، الإعلان يظهر فقط ككرت.",
                        "If you have a Place.id, tapping the ad opens place details. If empty, it shows as a normal ad card."
                    ))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                Section(header: Text(L("مدة الإعلان", "Ad duration"))) {
                    Text(L("إعلان مجاني لمدة 14 يوم، وبعدها يختفي.", "Free ad lasts 14 days, then it disappears."))
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Text(L("يمكنك نشر إعلان مجاني مرة واحدة بالشهر.", "You can publish one free ad per month."))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(L("إعلان مجاني", "Free Ad"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("إغلاق", "Close")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("نشر", "Publish")) { saveFreeAd() }
                }
            }
            .alert(L("تم", "Saved"), isPresented: $showSavedAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(L("تم نشر الإعلان لمدة 14 يوم.", "Your ad is published for 14 days."))
            }
        }
    }

    // MARK: - Preview copy
    private func previewCopy() -> String {
        let temp = Ad(
            tier: .free,
            status: .active,
            placeId: nil,
            imagePaths: [],
            businessName: businessName.isEmpty ? L("اسم المحل", "Business name") : businessName,
            ownerName: ownerName.isEmpty ? L("صاحب المحل", "Owner") : ownerName,
            phone: phone.isEmpty ? "000-000-0000" : phone,
            addressLine: addressLine.isEmpty ? L("العنوان", "Address") : addressLine,
            city: city.isEmpty ? L("المدينة", "City") : city,
            state: state.isEmpty ? L("NY", "NY") : state,
            businessType: businessType,
            template: template,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(14 * 24 * 60 * 60),
            freeCooldownKey: phone
        )
        return temp.generatedCopy(isArabic: lang.isArabic)
    }

    // MARK: - Load images
    private func loadImages(from items: [PhotosPickerItem]) async {
        pickedImages.removeAll()
        errorMessage = nil

        for item in items.prefix(3) {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                pickedImages.append(img)
            }
        }
    }

    // MARK: - Save Free Ad
    private func saveFreeAd() {
        errorMessage = nil

        // Trim
        let bName = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        let oName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let ph = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let addr = addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let st = state.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !bName.isEmpty else { errorMessage = L("اسم المحل مطلوب.", "Business name is required."); return }
        guard !oName.isEmpty else { errorMessage = L("اسم صاحب المحل مطلوب.", "Owner name is required."); return }
        guard !ph.isEmpty else { errorMessage = L("رقم الهاتف مطلوب.", "Phone is required."); return }
        guard !addr.isEmpty else { errorMessage = L("العنوان مطلوب.", "Address is required."); return }
        guard !c.isEmpty else { errorMessage = L("المدينة مطلوبة.", "City is required."); return }
        guard !st.isEmpty else { errorMessage = L("الولاية مطلوبة.", "State is required."); return }

        guard (1...3).contains(pickedImages.count) else {
            errorMessage = L("اختَر 1 إلى 3 صور.", "Pick 1 to 3 images.")
            return
        }

        // ✅ Monthly cooldown (by phone)
        guard adsStore.canCreateFreeAd(cooldownKey: ph) else {
            let days = adsStore.freeAdCooldownRemainingDays(cooldownKey: ph)
            errorMessage = L("لا يمكنك نشر إعلان مجاني الآن. حاول بعد \(days) يوم.", "You can’t post a free ad now. Try again in \(days) days.")
            return
        }

        // Save images locally
        let paths = pickedImages.compactMap { saveImageToDocuments($0) }

        // 14 days expiration
        let expires = Date().addingTimeInterval(14 * 24 * 60 * 60)

        let pid = placeIdOptional.trimmingCharacters(in: .whitespacesAndNewlines)
        let ad = Ad(
            tier: .free,
            status: .active,
            placeId: pid.isEmpty ? nil : pid,
            imagePaths: paths,
            businessName: bName,
            ownerName: oName,
            phone: ph,
            addressLine: addr,
            city: c,
            state: st,
            businessType: businessType,
            template: template,
            createdAt: Date(),
            expiresAt: expires,
            freeCooldownKey: ph
        )

        AdsStore.shared.add(ad)
        showSavedAlert = true
    }

    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.82) else { return nil }
        let filename = "ad_\(UUID().uuidString).jpg"

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            print("❌ save image error: \(error)")
            return nil
        }
    }
}
