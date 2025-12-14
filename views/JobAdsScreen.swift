import SwiftUI
import FirebaseFirestore
import Combine

// MARK: - Job type (two tabs)
enum JobFormType: String, CaseIterable, Identifiable {
    case seeking = "seeking"   // Looking for a job
    case hiring  = "hiring"    // Hiring staff

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .seeking: return "Looking for a job"
        case .hiring:  return "Hiring staff"
        }
    }

    var descriptionEN: String {
        switch self {
        case .seeking:
            return "Tell employers what type of job you’re looking for, your experience and best time to contact you."
        case .hiring:
            return "Describe your business, the open position, requirements and how applicants should contact you."
        }
    }
}

// MARK: - ViewModel
final class JobFormViewModel: ObservableObject {
    @Published var adType: JobFormType = .seeking

    // Basic info
    @Published var fullName: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var city: String = ""

    // Ad content
    @Published var headline: String = ""   // short title
    @Published var details: String = ""    // full description

    // State
    @Published var isSubmitting: Bool = false
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !headline.trimmingCharacters(in: .whitespaces).isEmpty &&
        !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func submit() {
        guard isFormValid else { return }

        isSubmitting = true
        errorMessage = nil

        let data: [String: Any] = [
            "kind"      : "job",                    // تمييز أنها وظيفة (النظام القديم)
            "jobType"   : adType.rawValue,          // seeking / hiring
            "fullName"  : fullName,
            "phone"     : phone,
            "email"     : email,
            "city"      : city,
            "headline"  : headline,
            "details"   : details,
            "createdAt" : FieldValue.serverTimestamp()
        ]

        db.collection("jobAds").addDocument(data: data) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSubmitting = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.showSuccess = true
                    self.resetForm()
                }
            }
        }
    }

    private func resetForm() {
        fullName = ""
        phone = ""
        email = ""
        city = ""
        headline = ""
        details = ""
    }
}

// MARK: - Job Ads Screen
struct JobAdsScreen: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var lang: LanguageManager
    @StateObject private var vm = JobFormViewModel()

    /// الزر الأخضر: يفتح صفحة الإعلانات المجانية (وظائف + فعاليات)
    @State private var showFreeAdsBoard: Bool = false

    var body: some View {
        NavigationStack {
            Form {

                // SECTION 0: شريطين الوظائف + زر أخضر للإعلانات المجانية
                Section {
                    headerStrips
                }

                // SECTION 1: نوع الإعلان (تبويبين ملونين)
                Section {
                    jobTypeSelector

                    Text(
                        L(
                            vm.adType == .seeking
                            ? "اخبر أصحاب العمل بنوع الوظيفة التي تبحث عنها وخبرتك وأفضل وقت للتواصل معك."
                            : "صف نشاطك التجاري، والوظيفة المتاحة، والمتطلبات، وطريقة التواصل."
                        ,
                            vm.adType.descriptionEN
                        )
                    )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }

                // SECTION 2: معلومات التواصل
                Section(header: Text(L("معلومات التواصل", "Contact information"))) {
                    TextField(L("الاسم الكامل", "Full name"), text: $vm.fullName)
                    TextField(L("رقم الهاتف", "Phone number"), text: $vm.phone)
                        .keyboardType(.phonePad)
                    TextField(L("البريد الإلكتروني (اختياري)", "Email (optional)"), text: $vm.email)
                        .keyboardType(.emailAddress)
                    TextField(L("المدينة / الولاية", "City / State"), text: $vm.city)
                }

                // SECTION 3: تفاصيل الإعلان
                Section(
                    header: Text(L("تفاصيل الإعلان", "Ad details")),
                    footer: Text(footerHint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                ) {
                    TextField(
                        vm.adType == .seeking
                        ? L("نوع الوظيفة المطلوبة (مثال: كاشير، طباخ…)", "Job you are looking for (e.g. Cashier, Cook…)")
                        : L("عنوان الوظيفة (مثال: كاشير، شيف، سائق…)", "Job title (e.g. Cashier, Chef, Driver…)"),
                        text: $vm.headline
                    )

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $vm.details)
                            .frame(minHeight: 120)

                        if vm.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(detailsPlaceholder)
                                .foregroundColor(.secondary.opacity(0.7))
                                .padding(.top, 8)
                                .padding(.horizontal, 5)
                                .allowsHitTesting(false)
                        }
                    }
                }

                // SECTION 4: زر الإرسال
                Section {
                    Button {
                        vm.submit()
                    } label: {
                        HStack {
                            if vm.isSubmitting {
                                ProgressView()
                            }
                            Text(L("إرسال إعلان الوظيفة", "Submit job ad"))
                        }
                    }
                    .disabled(!vm.isFormValid || vm.isSubmitting)
                }

                // SECTION 5: رسالة خطأ إن وجدت
                if let error = vm.errorMessage {
                    Section {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(L("إعلانات الوظائف", "Job Ads"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("إغلاق", "Close")) {
                        dismiss()
                    }
                }
            }
            .alert(
                L("تم إرسال إعلان الوظيفة", "Job ad sent"),
                isPresented: $vm.showSuccess
            ) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(
                    L(
                        "تم إرسال إعلان الوظيفة إلى فريق حلال ماب برايم لمراجعته.",
                        "Your job ad has been sent to Halal Map Prime team for review."
                    )
                )
            }
            // ✅ صفحة الإعلانات المجانية (وظائف + فعاليات)
            .sheet(isPresented: $showFreeAdsBoard) {
                JobAdsBoardView()
                    .environmentObject(lang)
            }
        }
    }

    // MARK: - Helper: localization
    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    // MARK: - Helper views & texts

    /// شريط أحمر + أزرق + زر أخضر واضح "إعلانات مجانية"
    private var headerStrips: some View {
        VStack(spacing: 8) {

            // 🔴 شريط أحمر
            jobStrip(
                text: L("🔍 تبحث عن عمل؟", "🔍 Looking for a job?"),
                background: .red
            )

            HStack(spacing: 8) {

                // 🔵 شريط أزرق
                jobStrip(
                    text: L("💼 يوجد شواغر عمل", "💼 Jobs available"),
                    background: .blue
                )

                // 🟢 زر أخضر واضح: صفحة الإعلانات المجانية (وظائف + فعاليات)
                Button {
                    showFreeAdsBoard = true
                } label: {
                    HStack {
                        Text(
                            L("📢 إعلانات مجانية", "📢 Free Ads")
                        )
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.green.opacity(0.96))
                    .cornerRadius(14)
                    .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func jobStrip(text: String, background: Color) -> some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(background.opacity(0.96))
        .cornerRadius(14)
        .shadow(color: background.opacity(0.3), radius: 6, x: 0, y: 3)
    }

    // تبويبين ملونين مطابقين للألوان (أحمر / أزرق)
    private var jobTypeSelector: some View {
        HStack(spacing: 0) {
            selectorButton(
                type: .seeking,
                title: L("أبحث عن عمل", "Looking for a job"),
                color: .red
            )
            selectorButton(
                type: .hiring,
                title: L("أبحث عن موظفين", "Hiring staff"),
                color: .blue
            )
        }
        .frame(height: 40)
        .clipShape(Capsule())
    }

    private func selectorButton(
        type: JobFormType,
        title: String,
        color: Color
    ) -> some View {
        Button {
            vm.adType = type
        } label: {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(vm.adType == type ? .white : .primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 4)
                .background(
                    vm.adType == type
                    ? color
                    : Color(.systemGray5)
                )
        }
        .buttonStyle(.plain)
    }

    private var footerHint: String {
        switch vm.adType {
        case .seeking:
            return L(
                "أضف خبرتك، اللغات، ساعات العمل وأي معلومات مهمة تساعد أصحاب العمل على التواصل معك.",
                "Add your experience, languages, work hours and any important information to help employers contact you."
            )
        case .hiring:
            return L(
                "أضف معلومات عن المطعم / النشاط، ساعات العمل، نطاق الراتب والمتطلبات.",
                "Add information about the restaurant / business, work hours, salary range and requirements."
            )
        }
    }

    private var detailsPlaceholder: String {
        switch vm.adType {
        case .seeking:
            return L(
                "مثال: أبحث عن وظيفة بدوام كامل كطباخ في بروكلين.\nلدي أكثر من ٣ سنوات خبرة في المطاعم الحلال وأستطيع العمل في المساء وعطلة نهاية الأسبوع.",
                "Example: I’m looking for a full-time job as a cook in Brooklyn.\nI have 3+ years experience in halal restaurants and I can work evenings and weekends."
            )
        case .hiring:
            return L(
                "مثال: نحن مطعم حلال في كوينز نبحث عن موظف كاشير بدوام كامل.\nمفضل إجادة الإنجليزية/العربية. دوام مسائي. الرجاء ذكر أفضل وقت للاتصال.",
                "Example: We are a halal restaurant in Queens looking for a full-time cashier.\nFluent English/Arabic preferred. Evening shift. Please include best time to call."
            )
        }
    }
}

