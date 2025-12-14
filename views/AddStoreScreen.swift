import SwiftUI

struct AddStoreScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var vm = AddStoreViewModel()

    @State private var requestHalalVerification = false

    // MARK: - Static Strings (compiler-safe)

    private let titleAR = "أضف عنوانك"
    private let titleEN = "Add Location"

    private let subtitleAR = "املأ المعلومات بالأسفل. سنراجع الإضافة قبل ظهورها على الخريطة."
    private let subtitleEN = "Please fill in the details below. We'll review the submission before it appears on the map."

    private let submitAR = "إرسال"
    private let submitEN = "Submit"

    private let successBaseAR = "تم استلام طلبك. سنراجعه ثم نضيفه على الخريطة إن شاء الله."
    private let successBaseEN = "Your submission has been received. We'll review it and add it to the map."

    private let verifyHintAR = "للحصول على (Verified Halal)، يرجى إرسال إثبات (فاتورة أو صورة للمحل) على واتساب:"
    private let verifyHintEN = "To get “Verified Halal”, please send proof (receipt or store photo) to WhatsApp:"

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
    }    // MARK: - BODY (very small)

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(lang.isArabic ? titleAR : titleEN)
                .navigationBarTitleDisplayMode(.inline)
                .alert(lang.isArabic ? "شكراً لك!" : "Thank you!",
                       isPresented: $vm.showSuccessAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(successMessage)
                }
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
    }

    // MARK: - SECTIONS

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lang.isArabic ? titleAR : titleEN)
                .font(.title2.bold())

            Text(lang.isArabic ? subtitleAR : subtitleEN)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.isArabic ? "التصنيف" : "Category")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PlaceCategory.allCases) { category in
                        Button {
                            vm.selectedCategory = category
                        } label: {
                            Text(lang.isArabic ? categoryLabelAR(category) : category.rawValue)                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    vm.selectedCategory == category
                                    ? Color.blue.opacity(0.2)
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
    }

    private var verificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(
                lang.isArabic
                ? "طلب توثيق (Verified Halal)"
                : "Request Verified Halal",
                isOn: $requestHalalVerification
            )
            .tint(.orange)

            if requestHalalVerification {
                Text(
                    isFoodCategory
                    ? (lang.isArabic
                       ? "بعد الإرسال: أرسل فاتورة أو صورة للمحل على واتساب."
                       : "After submitting: send a receipt or store photo to WhatsApp.")
                    : (lang.isArabic
                       ? "التوثيق مخصص عادة لأماكن الطعام فقط."
                       : "Verification is typically for food places only.")
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
            TextField(lang.isArabic ? "اسم المكان" : "Place name", text: $vm.name)
                .textFieldStyle(.roundedBorder)

            TextField(lang.isArabic ? "العنوان" : "Address", text: $vm.address)
                .textFieldStyle(.roundedBorder)

            HStack {
                TextField(lang.isArabic ? "المدينة" : "City", text: $vm.city)
                    .textFieldStyle(.roundedBorder)

                TextField(lang.isArabic ? "الولاية" : "State", text: $vm.state)
                    .textFieldStyle(.roundedBorder)
            }

            TextField(lang.isArabic ? "الهاتف" : "Phone", text: $vm.phone)
                .textFieldStyle(.roundedBorder)

            TextField(lang.isArabic ? "الموقع الإلكتروني" : "Website (optional)", text: $vm.website)
                .textFieldStyle(.roundedBorder)

            TextField(lang.isArabic ? "ملاحظات" : "Notes (optional)", text: $vm.notes, axis: .vertical)
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
                    ? (lang.isArabic ? "جارٍ الإرسال..." : "Submitting...")
                    : (lang.isArabic ? submitAR : submitEN)
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
        }
    }
}
