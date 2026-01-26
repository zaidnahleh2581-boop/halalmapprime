//
//  AddPlaceScreen.swift
//  Halal Map Prime
//
//  FINAL – Stable Add Place Flow + Clear Business Logic
//  Created by Zaid Nahleh
//

import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

struct AddPlaceScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Pin Item (annotationItems requires Identifiable)
    struct PinItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    // MARK: - Map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    @State private var pickedCoordinate: CLLocationCoordinate2D? = nil
    private let geocoder = CLGeocoder()

    // MARK: - Form Fields
    @State private var placeName = ""
    @State private var ownerName = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var phone = ""
    @State private var website = ""

    @State private var selectedCategoryId: String =
        HMPPlaceCategoryCatalog.all.first?.id ?? "community.center"

    // MARK: - UI State
    @State private var isSaving = false
    @State private var errorText: String?
    @State private var successText: String?

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    // MARK: - Computed Logic
    private var selectedCategory: HMPPlaceCategoryItem? {
        HMPPlaceCategoryCatalog.item(for: selectedCategoryId)
    }

    private var needsApproval: Bool {
        selectedCategory?.requiresApproval ?? false
    }

    private var flowExplanationText: String {
        if needsApproval {
            return L(
                """
                ✅ كيف تمشي الخطوات؟
                1) أضف معلومات المحل وحدد الموقع على الخريطة.
                2) إذا كان المكان (مطعم / فود ترك / ملحمة / بقالة أو أي مكان طعام):
                   سيظهر الطلب "قيد المراجعة" ولن يظهر على الخريطة فورًا.
                3) الإدارة ستراجع البيانات للتأكد من صحة المعلومات ومنع التكرار.
                4) بعد الموافقة سيظهر مكانك على الخريطة مباشرة.
                """,
                """
                ✅ How it works:
                1) Add your place details and pin the location on the map.
                2) If it's a food place (Restaurant / Food Truck / Butcher / Grocery, etc.):
                   it will be marked as “Pending Review” and will NOT appear immediately.
                3) Admin reviews the info to verify accuracy and avoid duplicates.
                4) Once approved, your place appears on the map instantly.
                """
            )
        } else {
            return L(
                """
                ✅ كيف تمشي الخطوات؟
                1) أضف معلومات المكان وحدد الموقع على الخريطة.
                2) إذا كان المكان (مسجد / مدرسة / مركز / خدمات / محامي / صيدلية...):
                   سيظهر مباشرة على الخريطة بدون انتظار.
                """,
                """
                ✅ How it works:
                1) Add your place details and pin the location on the map.
                2) If it's a non-food place (Mosque / School / Center / Services / Lawyer / Pharmacy...):
                   it appears on the map immediately (no waiting).
                """
            )
        }
    }

    private var pins: [PinItem] {
        if let c = pickedCoordinate { return [PinItem(coordinate: c)] }
        return []
    }

    // MARK: - BODY
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                mapSection

                infoSection

                explanationSection

                if let errorText {
                    Text(errorText)
                        .foregroundColor(.red)
                        .font(.footnote.weight(.semibold))
                }

                if let successText {
                    Text(successText)
                        .foregroundColor(.green)
                        .font(.footnote.weight(.semibold))
                }

                submitButton
            }
            .padding()
        }
        .navigationTitle(L("أضف عنوانك", "Add Your Place"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
        .onAppear {
            ensureAnonymousAuth()
        }
    }

    // MARK: - Map
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(L("حدد موقعك على الخريطة", "Select location on map"))
                .font(.headline)

            Map(
                coordinateRegion: $region,
                annotationItems: pins
            ) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.red)
                }
            }
            .frame(height: 220)
            .cornerRadius(16)
            .onTapGesture {
                let center = region.center
                pickedCoordinate = center
                reverseGeocode(center)
            }

            Text(L(
                "حرّك الخريطة ثم اضغط لتثبيت الموقع.",
                "Move the map then tap to pin your location."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Form
    private var infoSection: some View {
        VStack(spacing: 12) {

            TextField(L("اسم المحل", "Business name"), text: $placeName)
                .textFieldStyle(.roundedBorder)

            TextField(L("اسم صاحب المحل", "Owner name"), text: $ownerName)
                .textFieldStyle(.roundedBorder)

            Picker(L("التصنيف", "Category"), selection: $selectedCategoryId) {
                ForEach(HMPPlaceCategoryCatalog.all) { item in
                    Text(lang.isArabic ? item.ar : item.en)
                        .tag(item.id)
                }
            }

            TextField(L("العنوان", "Address"), text: $address)
                .textFieldStyle(.roundedBorder)

            HStack {
                TextField(L("المدينة", "City"), text: $city)
                    .textFieldStyle(.roundedBorder)
                TextField(L("الولاية", "State"), text: $state)
                    .textFieldStyle(.roundedBorder)
            }

            TextField(L("الهاتف", "Phone"), text: $phone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)

            TextField(L("الموقع الإلكتروني", "Website"), text: $website)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }

    // MARK: - Explanation
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: needsApproval ? "clock.fill" : "checkmark.seal.fill")
                Text(needsApproval ? L("سيحتاج موافقة الإدارة", "Requires admin approval")
                                   : L("سيظهر مباشرة", "Appears immediately"))
                    .font(.headline)
            }

            Text(flowExplanationText)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    // MARK: - Submit
    private var submitButton: some View {
        Button {
            save()
        } label: {
            HStack {
                if isSaving {
                    ProgressView().padding(.trailing, 6)
                }
                Text(isSaving ? L("جاري الإرسال…", "Submitting…")
                              : L("إرسال", "Submit"))
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isSaving)
    }

    // MARK: - Save Logic
    private func save() {
        errorText = nil
        successText = nil

        let n = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let o = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let s = state.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !n.isEmpty, !o.isEmpty, !a.isEmpty, !c.isEmpty, !s.isEmpty else {
            errorText = L("رجاءً املأ الحقول المطلوبة.", "Please fill required fields.")
            return
        }

        guard let coord = pickedCoordinate else {
            errorText = L("حدد الموقع على الخريطة أولاً.", "Please pin the location on the map.")
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            errorText = L("لا يوجد مستخدم مسجل.", "No signed-in user.")
            return
        }

        let approved = !needsApproval

        isSaving = true

        let data: [String: Any] = [
            "name": n,
            "ownerName": o,

            "address": a,
            "city": c,
            "state": s,
            "cityState": "\(c), \(s)",

            "latitude": coord.latitude,
            "longitude": coord.longitude,

            "phone": phone.trimmingCharacters(in: .whitespacesAndNewlines),
            "website": website.trimmingCharacters(in: .whitespacesAndNewlines),

            "categoryId": selectedCategoryId,
            "ownerUid": uid,

            "approvalRequired": needsApproval,
            "isApproved": approved,
            "approvedAt": approved ? FieldValue.serverTimestamp() : NSNull(),

            "createdAt": FieldValue.serverTimestamp()
        ]

        Firestore.firestore()
            .collection("places")
            .addDocument(data: data) { err in
                DispatchQueue.main.async {
                    self.isSaving = false

                    if let err {
                        self.errorText = err.localizedDescription
                        return
                    }

                    self.successText = approved
                        ? self.L("تمت الإضافة وظهرت على الخريطة ✅",
                                 "Added and visible on map ✅")
                        : self.L("تم الإرسال ✅ بانتظار موافقة الإدارة ⏳",
                                 "Submitted ✅ pending admin approval ⏳")

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.clearForm()
                }
            }
    }

    private func clearForm() {
        placeName = ""
        ownerName = ""
        address = ""
        city = ""
        state = ""
        phone = ""
        website = ""
        pickedCoordinate = nil
        selectedCategoryId = HMPPlaceCategoryCatalog.all.first?.id ?? "community.center"
    }

    // MARK: - Reverse Geocode
    private func reverseGeocode(_ coord: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(
            CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        ) { placemarks, _ in
            guard let p = placemarks?.first else { return }

            DispatchQueue.main.async {
                let street = p.thoroughfare ?? ""
                let num = p.subThoroughfare ?? ""
                let line = [num, street].filter { !$0.isEmpty }.joined(separator: " ")
                if !line.isEmpty { self.address = line }
                if let loc = p.locality, !loc.isEmpty { self.city = loc }
                if let st = p.administrativeArea, !st.isEmpty { self.state = st }
            }
        }
    }

    // MARK: - Ensure Anonymous Auth (Stable / No future crashes)
    private func ensureAnonymousAuth() {
        if Auth.auth().currentUser != nil { return }
        Auth.auth().signInAnonymously { _, _ in }
    }
}
