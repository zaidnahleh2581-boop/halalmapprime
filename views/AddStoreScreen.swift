//
//  AddStoreScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import SwiftUI

struct AddStoreScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var vm = AddStoreViewModel()

    @State private var requestHalalVerification = false

    // MARK: - Copy (compiler-safe)

    private let titleAR = "وثّق موقعك"
    private let titleEN = "Verify your location"

    private let subtitleAR = "املأ المعلومات بالأسفل. سنراجع الطلب قبل ظهور الموقع على الخريطة."
    private let subtitleEN = "Fill in the details below. We review submissions before they appear on the map."

    private let submitAR = "إرسال الطلب"
    private let submitEN = "Submit request"

    private let successBaseAR = "تم استلام طلبك. سنراجعه ثم نضيفه على الخريطة إن شاء الله."
    private let successBaseEN = "Your submission has been received. We'll review it and add it to the map."

    private let verifyHintAR = "للحصول على (Halal Verified)، يرجى إرسال إثبات (فاتورة أو صورة للمحل) على واتساب:"
    private let verifyHintEN = "To get “Halal Verified”, please send proof (receipt or store photo) to WhatsApp:"

    private let whatsappNumber = "+1 (631) 947-8782"

    // MARK: - Helpers

    private var isFoodCategory: Bool {
        switch vm.selectedCategory {
        case .restaurant, .grocery, .foodTruck, .market:
            return true
        default:
            return false
        }
    }

    private var successMessage: String {
        let base = lang.isArabic ? successBaseAR : successBaseEN
        if requestHalalVerification && isFoodCategory {
            let verify = lang.isArabic ? verifyHintAR : verifyHintEN
            return "\(base)\n\n\(verify)\n\(whatsappNumber)"
        }
        return base
    }

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private func categoryLabelAR(_ category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return "مطعم"
        case .grocery: return "بقالة"
        case .foodTruck: return "فود ترك"
        case .market: return "سوق"
        case .mosque: return "مسجد"
        case .school: return "مدرسة"
        case .service: return "خدمة"
        case .shop: return "محل"
        case .center: return "مركز"
        case .funeral: return "مغسلة/دفن"
        default: return "أخرى"
        }
    }

    private func categoryLabelEN(_ category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return "Restaurant"
        case .grocery: return "Grocery"
        case .foodTruck: return "Food truck"
        case .market: return "Market"
        case .mosque: return "Masjid"
        case .school: return "School"
        case .service: return "Service"
        case .shop: return "Shop"
        case .center: return "Center"
        case .funeral: return "Funeral service"
        default: return "Other"
        }
    }

    private func categoryTitle(_ category: PlaceCategory) -> String {
        lang.isArabic ? categoryLabelAR(category) : categoryLabelEN(category)
    }

    // MARK: - BODY

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(lang.isArabic ? titleAR : titleEN)
                .navigationBarTitleDisplayMode(.inline)

                // Success
                .alert(lang.isArabic ? "شكراً لك!" : "Thank you!",
                       isPresented: $vm.showSuccessAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(successMessage)
                }

                // Validation
                .alert(lang.isArabic ? "يرجى تعبئة الحقول المطلوبة" : "Please fill all required fields",
                       isPresented: $vm.showValidationAlert) {
                    Button("OK", role: .cancel) { }
                }
        }
    }

    // MARK: - CONTENT

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                categorySection
                verificationSection
                fieldsSection
                submitSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - SECTIONS

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L(titleAR, titleEN))
                .font(.title2.bold())

            Text(L(subtitleAR, subtitleEN))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("نوع الموقع", "Place type"))
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PlaceCategory.allCases) { category in
                        Button {
                            vm.selectedCategory = category
                        } label: {
                            Text(categoryTitle(category))
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    vm.selectedCategory == category
                                    ? Color.blue.opacity(0.20)
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Text(L("اختر التصنيف الأقرب لمكانك. هذا يساعدنا في ترتيب ظهور الموقع داخل التطبيق.",
                   "Choose the closest category. This helps us organize how your place appears in the app."))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }

    private var verificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Toggle(
                L("أريد شارة Halal Verified (اختياري)", "I want a Halal Verified badge (optional)"),
                isOn: $requestHalalVerification
            )
            .tint(.orange)

            if requestHalalVerification {
                Text(
                    isFoodCategory
                    ? L("بعد الإرسال: أرسل فاتورة أو صورة للمحل على واتساب لإكمال التوثيق.",
                        "After submitting: send a receipt or store photo to WhatsApp to complete verification.")
                    : L("التوثيق عادة مخصص لأماكن الطعام فقط. يمكنك المتابعة بدون توثيق.",
                        "Verification is typically for food places. You can continue without verification.")
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    private var fieldsSection: some View {
        Group {
            TextField(L("اسم المكان", "Place name"), text: $vm.name)
                .textFieldStyle(.roundedBorder)

            TextField(L("العنوان", "Address"), text: $vm.address)
                .textFieldStyle(.roundedBorder)

            HStack {
                TextField(L("المدينة", "City"), text: $vm.city)
                    .textFieldStyle(.roundedBorder)

                TextField(L("الولاية", "State"), text: $vm.state)
                    .textFieldStyle(.roundedBorder)
            }

            TextField(L("الهاتف", "Phone"), text: $vm.phone)
                .textFieldStyle(.roundedBorder)

            TextField(L("الموقع الإلكتروني (اختياري)", "Website (optional)"), text: $vm.website)
                .textFieldStyle(.roundedBorder)

            TextField(L("ملاحظات (اختياري)", "Notes (optional)"), text: $vm.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3, reservesSpace: true)
        }
    }

    private var submitSection: some View {
        VStack(spacing: 12) {
            Button {
                vm.submit()
            } label: {
                Text(
                    vm.isSubmitting
                    ? L("جارٍ الإرسال...", "Submitting...")
                    : L(submitAR, submitEN)
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isSubmitting)

            if vm.isSubmitting {
                ProgressView()
            }

            // WhatsApp hint (always visible but subtle)
            Text(L("للتوثيق أو الاستفسار: واتساب \(whatsappNumber)",
                   "For verification or questions: WhatsApp \(whatsappNumber)"))
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.top, 2)
        }
    }
}
