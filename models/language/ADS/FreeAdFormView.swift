import SwiftUI
import FirebaseFirestore

/// نموذج الإعلان المجاني (مرة واحدة لكل حساب)
struct FreeAdFormView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // بيانات بسيطة للنموذج
    @State private var fullName: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var city: String = ""
    @State private var category: String = ""

    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isSubmitting: Bool = false

    private let db = Firestore.firestore()

    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !details.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !category.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section(
                header: Text(lang.isArabic ? "معلومات التواصل" : "Contact information")
            ) {
                TextField(lang.isArabic ? "الاسم الكامل" : "Full name", text: $fullName)
                TextField(lang.isArabic ? "رقم الهاتف" : "Phone number", text: $phone)
                    .keyboardType(.phonePad)
                TextField(lang.isArabic ? "البريد الإلكتروني (اختياري)" : "Email (optional)", text: $email)
                    .keyboardType(.emailAddress)
            }

            Section(
                header: Text(lang.isArabic ? "تفاصيل الإعلان" : "Ad details")
            ) {
                TextField(lang.isArabic ? "عنوان قصير للإعلان" : "Short ad title", text: $title)

                TextField(
                    lang.isArabic ? "اكتب نص الإعلان بالتفصيل" : "Write your ad text in detail",
                    text: $details,
                    axis: .vertical
                )
                .lineLimit(3...6)

                TextField(lang.isArabic ? "المدينة / المنطقة" : "City / area", text: $city)

                TextField(
                    lang.isArabic ? "نوع الإعلان (مثال: فعالية، إعلان مجتمعي…)" :
                                     "Ad type (e.g. event, community notice...)",
                    text: $category
                )
            }

            Section {
                Button {
                    submitAd()
                } label: {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                        }
                        Text(lang.isArabic ? "إرسال الإعلان المجاني" : "Submit free ad")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!isFormValid || isSubmitting)
            }

            Section(
                footer: Text(
                    lang.isArabic
                    ? "سيتم استخدام هذا النموذج للإعلانات المجتمعية المجانية فقط، وليس للإعلانات التجارية المدفوعة."
                    : "This form is only for free community announcements, not for paid business ads."
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            ) {
                EmptyView()
            }
        }
        .navigationTitle(lang.isArabic ? "إعلان مجاني" : "Free community ad")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text(lang.isArabic ? "حسناً" : "OK")) {
                    // لو بدك تسكر الشاشة بعد النجاح
                    if alertTitle == (lang.isArabic ? "تم الإرسال" : "Submitted") {
                        dismiss()
                    }
                }
            )
        }
    }

    private func submitAd() {
        guard isFormValid else { return }

        isSubmitting = true

        let data: [String: Any] = [
            "fullName": fullName.trimmingCharacters(in: .whitespaces),
            "phone": phone.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces),
            "title": title.trimmingCharacters(in: .whitespaces),
            "details": details.trimmingCharacters(in: .whitespaces),
            "city": city.trimmingCharacters(in: .whitespaces),
            "category": category.trimmingCharacters(in: .whitespaces),
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("communityAds").addDocument(data: data) { error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertTitle = lang.isArabic ? "خطأ" : "Error"
                    alertMessage = error.localizedDescription
                } else {
                    alertTitle = lang.isArabic ? "تم الإرسال" : "Submitted"
                    alertMessage =
                    lang.isArabic
                    ? "تم إرسال إعلانك المجاني بنجاح وسيظهر بعد المراجعة."
                    : "Your free community ad was submitted successfully and will appear after review."
                    
                    // تنظيف الحقول
                    fullName = ""
                    phone = ""
                    email = ""
                    title = ""
                    details = ""
                    city = ""
                    category = ""
                }
                showAlert = true
            }
        }
    }
}

struct FreeAdFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FreeAdFormView()
                .environmentObject(LanguageManager())
        }
    }
}
