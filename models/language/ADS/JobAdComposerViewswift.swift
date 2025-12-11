//
//  JobAdComposerView.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import SwiftUI
import FirebaseFirestore

struct JobAdComposerView: View {

    // MARK: - Environment

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Types داخلية (لن تتعارض مع أي شيء خارج الملف)

    /// نوع صاحب الإعلان: باحث عن عمل أو صاحب عمل
    private enum AdRole: String, CaseIterable, Identifiable {
        case lookingForJob   // باحث عن عمل
        case hiring          // صاحب عمل

        var id: String { rawValue }

        var titleArabic: String {
            switch self {
            case .lookingForJob: return "أبحث عن عمل"
            case .hiring:        return "أبحث عن موظف"
            }
        }

        var titleEnglish: String {
            switch self {
            case .lookingForJob: return "Looking for a job"
            case .hiring:        return "Hiring"
            }
        }

        var firestoreValue: String {
            switch self {
            case .lookingForJob: return "lookingForJob"
            case .hiring:        return "hiring"
            }
        }
    }

    /// قطاع العمل
    private enum JobSectorOption: String, CaseIterable, Identifiable {
        case restaurants
        case supermarkets
        case butcher
        case shops
        case mosques
        case schools
        case professional
        case construction

        var id: String { rawValue }

        var titleArabic: String {
            switch self {
            case .restaurants:  return "مطاعم وكافيهات"
            case .supermarkets: return "سوبرماركت وبقالات"
            case .butcher:      return "ملاحم"
            case .shops:        return "محلات تجارية"
            case .mosques:      return "مساجد ومراكز"
            case .schools:      return "مدارس"
            case .professional: return "وظائف مهنية"
            case .construction: return "بناء وكهرباء وسباكة"
            }
        }

        var titleEnglish: String {
            switch self {
            case .restaurants:  return "Restaurants & Cafes"
            case .supermarkets: return "Supermarkets & Groceries"
            case .butcher:      return "Butcher shops"
            case .shops:        return "Retail shops"
            case .mosques:      return "Mosques & centers"
            case .schools:      return "Schools"
            case .professional: return "Professional jobs"
            case .construction: return "Construction / Electric / Plumbing"
            }
        }
    }

    /// قالب جملة جاهزة
    private struct JobTemplate: Identifiable {
        let id: Int
        let role: AdRole
        let sector: JobSectorOption
        let ar: String
        let en: String
    }

    // MARK: - بيانات الفورم

    @State private var ownerName: String = ""
    @State private var city: String = ""
    @State private var phone: String = ""

    @State private var selectedRole: AdRole = .lookingForJob
    @State private var selectedSector: JobSectorOption = .restaurants

    @State private var searchText: String = ""
    @State private var selectedTemplateIndex: Int = 0

    // حالة الحفظ
    @State private var isSaving: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    private let collection = Firestore.firestore().collection("jobAds")

    // MARK: - القوالب

    private let allTemplates: [JobTemplate] = [
        // مطاعم – باحث عن عمل
        .init(id: 1, role: .lookingForJob, sector: .restaurants,
              ar: "أبحث عن عمل ككاشير في مطعم.",
              en: "Looking for a job as a cashier in a restaurant."),
        .init(id: 2, role: .lookingForJob, sector: .restaurants,
              ar: "أبحث عن عمل كعامل مطبخ في مطعم.",
              en: "Looking for a job as a kitchen helper in a restaurant."),
        .init(id: 3, role: .lookingForJob, sector: .restaurants,
              ar: "أبحث عن عمل كطباخ شرقي.",
              en: "Looking for a job as an oriental cook."),
        .init(id: 4, role: .lookingForJob, sector: .restaurants,
              ar: "أبحث عن عمل كجريل مان.",
              en: "Looking for a job as a grill man."),
        .init(id: 5, role: .lookingForJob, sector: .restaurants,
              ar: "أبحث عن عمل في مطعم بدوام كامل.",
              en: "Looking for a full-time job in a restaurant."),
        .init(id: 6, role: .lookingForJob, sector: .restaurants,
              ar: "أبحث عن عمل في مطعم بدوام جزئي.",
              en: "Looking for a part-time job in a restaurant."),

        // مطاعم – صاحب عمل
        .init(id: 101, role: .hiring, sector: .restaurants,
              ar: "مطلوب موظف كاشير للعمل في مطعم.",
              en: "Hiring a cashier for a restaurant."),
        .init(id: 102, role: .hiring, sector: .restaurants,
              ar: "مطلوب طباخ شرقي لمطعم.",
              en: "Hiring an oriental cook for a restaurant."),
        .init(id: 103, role: .hiring, sector: .restaurants,
              ar: "مطلوب جريل مان ذو خبرة.",
              en: "Hiring an experienced grill man."),

        // سوبرماركت – باحث عن عمل
        .init(id: 7, role: .lookingForJob, sector: .supermarkets,
              ar: "أبحث عن عمل كموظف سوبرماركت.",
              en: "Looking for a job as a supermarket worker."),
        .init(id: 8, role: .lookingForJob, sector: .supermarkets,
              ar: "أبحث عن عمل كمرتب بضائع.",
              en: "Looking for a job as a stock organizer."),
        .init(id: 9, role: .lookingForJob, sector: .supermarkets,
              ar: "أبحث عن عمل ككاشير سوبرماركت.",
              en: "Looking for a job as a supermarket cashier."),

        // سوبرماركت – صاحب عمل
        .init(id: 104, role: .hiring, sector: .supermarkets,
              ar: "مطلوب موظفين للعمل في سوبرماركت.",
              en: "Hiring staff for a supermarket."),
        .init(id: 105, role: .hiring, sector: .supermarkets,
              ar: "مطلوب مرتب بضائع.",
              en: "Hiring a stock organizer."),
        .init(id: 106, role: .hiring, sector: .supermarkets,
              ar: "مطلوب كاشير.",
              en: "Hiring a cashier."),

        // ملاحم – باحث عن عمل
        .init(id: 10, role: .lookingForJob, sector: .butcher,
              ar: "أبحث عن عمل في ملحمة.",
              en: "Looking for a job in a butcher shop."),
        .init(id: 11, role: .lookingForJob, sector: .butcher,
              ar: "أبحث عن عمل كمساعد جزار.",
              en: "Looking for a job as a butcher assistant."),

        // ملاحم – صاحب عمل
        .init(id: 107, role: .hiring, sector: .butcher,
              ar: "مطلوب جزار ذو خبرة.",
              en: "Hiring an experienced butcher."),
        .init(id: 108, role: .hiring, sector: .butcher,
              ar: "مطلوب مساعد جزار.",
              en: "Hiring a butcher assistant."),

        // محلات – باحث عن عمل
        .init(id: 12, role: .lookingForJob, sector: .shops,
              ar: "أبحث عن عمل في محل ملابس.",
              en: "Looking for a job in a clothing store."),
        .init(id: 13, role: .lookingForJob, sector: .shops,
              ar: "أبحث عن عمل في محل هواتف.",
              en: "Looking for a job in a phone shop."),

        // محلات – صاحب عمل
        .init(id: 109, role: .hiring, sector: .shops,
              ar: "مطلوب موظف مبيعات لمحل تجاري.",
              en: "Hiring a sales person for a retail shop."),

        // مساجد – باحث عن عمل
        .init(id: 14, role: .lookingForJob, sector: .mosques,
              ar: "أبحث عن عمل كمؤذن.",
              en: "Looking for a job as a muezzin."),
        .init(id: 15, role: .lookingForJob, sector: .mosques,
              ar: "أبحث عن عمل كمدرس قرآن.",
              en: "Looking for a job as a Quran teacher."),

        // مساجد – صاحب عمل
        .init(id: 110, role: .hiring, sector: .mosques,
              ar: "مطلوب معلم قرآن.",
              en: "Hiring a Quran teacher."),

        // مدارس – باحث عن عمل
        .init(id: 16, role: .lookingForJob, sector: .schools,
              ar: "أبحث عن عمل كمعلم.",
              en: "Looking for a job as a teacher."),
        .init(id: 17, role: .lookingForJob, sector: .schools,
              ar: "أبحث عن عمل كمساعد معلم.",
              en: "Looking for a job as a teacher assistant."),

        // مدارس – صاحب عمل
        .init(id: 111, role: .hiring, sector: .schools,
              ar: "مطلوب معلم لمدرسة خاصة.",
              en: "Hiring a teacher for a private school."),

        // مهن – باحث عن عمل
        .init(id: 18, role: .lookingForJob, sector: .professional,
              ar: "أنا محاسب أبحث عن عمل.",
              en: "I am an accountant looking for a job."),
        .init(id: 19, role: .lookingForJob, sector: .professional,
              ar: "أنا محامي أبحث عن عمل.",
              en: "I am a lawyer looking for a job."),
        .init(id: 20, role: .lookingForJob, sector: .professional,
              ar: "أنا صيدلاني أبحث عن عمل.",
              en: "I am a pharmacist looking for a job."),

        // بناء / كهرباء / سباكة – باحث عن عمل
        .init(id: 21, role: .lookingForJob, sector: .construction,
              ar: "أبحث عن عمل في مجال البناء.",
              en: "Looking for a job in construction."),
        .init(id: 22, role: .lookingForJob, sector: .construction,
              ar: "أبحث عن عمل ككهربائي.",
              en: "Looking for a job as an electrician."),
        .init(id: 23, role: .lookingForJob, sector: .construction,
              ar: "أبحث عن عمل كسبّاك.",
              en: "Looking for a job as a plumber.")
    ]

    private var filteredTemplates: [JobTemplate] {
        let base = allTemplates.filter {
            $0.role == selectedRole && $0.sector == selectedSector
        }

        let q = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }

        return base.filter { t in
            t.ar.lowercased().contains(q) || t.en.lowercased().contains(q)
        }
    }

    private var selectedTemplate: JobTemplate? {
        guard !filteredTemplates.isEmpty else { return nil }
        if selectedTemplateIndex >= filteredTemplates.count {
            return filteredTemplates.first
        }
        return filteredTemplates[selectedTemplateIndex]
    }

    private var isFormValid: Bool {
        !ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedTemplate != nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                // بيانات المعلن
                Section(header: Text(lang.isArabic ? "بيانات المعلن" : "Advertiser info")) {
                    TextField(lang.isArabic ? "الاسم (مثال: خالد)" : "Name (e.g. Khaled)",
                              text: $ownerName)

                    TextField(lang.isArabic ? "المدينة / المنطقة (مثال: بروكلين)" : "City / area (e.g. Brooklyn)",
                              text: $city)

                    TextField(lang.isArabic ? "رقم الهاتف" : "Phone number",
                              text: $phone)
                        .keyboardType(.numbersAndPunctuation)
                }

                // نوع الإعلان
                Section(header: Text(lang.isArabic ? "نوع الإعلان" : "Ad type")) {
                    Picker("", selection: $selectedRole) {
                        ForEach(AdRole.allCases) { role in
                            Text(lang.isArabic ? role.titleArabic : role.titleEnglish)
                                .tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // القطاع
                Section(header: Text(lang.isArabic ? "قطاع العمل" : "Job sector")) {
                    Picker(lang.isArabic ? "اختر الفئة" : "Select sector",
                           selection: $selectedSector) {
                        ForEach(JobSectorOption.allCases) { sector in
                            Text(lang.isArabic ? sector.titleArabic : sector.titleEnglish)
                                .tag(sector)
                        }
                    }
                }

                // القوالب
                Section(header: Text(lang.isArabic ? "اختيار جملة جاهزة" : "Choose a template")) {
                    TextField(lang.isArabic ? "بحث داخل الجمل..." : "Search templates...",
                              text: $searchText)

                    if filteredTemplates.isEmpty {
                        Text(lang.isArabic ? "لا توجد قوالب مطابقة." : "No matching templates.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker(lang.isArabic ? "الجملة" : "Phrase",
                               selection: $selectedTemplateIndex) {
                            ForEach(Array(filteredTemplates.enumerated()), id: \.offset) { index, template in
                                Text(lang.isArabic ? template.ar : template.en)
                                    .tag(index)
                                    .lineLimit(2)
                            }
                        }
                    }
                }

                // معاينة الإعلان
                Section(header: Text(lang.isArabic ? "معاينة الإعلان" : "Preview")) {
                    if let preview = previewText {
                        Text(preview)
                            .font(.subheadline)
                    } else {
                        Text(lang.isArabic ? "اختر جملة جاهزة لمعاينة الإعلان." :
                             "Select a template to preview the ad.")
                            .foregroundColor(.secondary)
                    }
                }

                // زر النشر المجاني (القواعد المتفق عليها من ناحية المنطق)
                Section {
                    Button {
                        attemptPublishFree()
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text(lang.isArabic ? "نشر إعلان مجاني" : "Publish free ad")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .navigationTitle(lang.isArabic ? "إعلان وظيفة" : "Job ad")
            .navigationBarTitleDisplayMode(.inline)
            .alert(lang.isArabic ? "تم الحفظ" : "Saved",
                   isPresented: $showSuccessAlert) {
                Button(lang.isArabic ? "إغلاق" : "Close") {
                    dismiss()
                }
            } message: {
                Text(lang.isArabic ?
                     "تم إرسال إعلانك المجاني بنجاح، وسيظهر في قائمة إعلانات الوظائف لمدة ٧ أيام." :
                     "Your free job ad was posted successfully and will appear in the job ads list for 7 days.")
            }
            .alert(lang.isArabic ? "خطأ" : "Error",
                   isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Preview text

    private var previewText: String? {
        guard let template = selectedTemplate else { return nil }

        let line1 = "\(ownerName) – \(city) – \(phone)"
        let arText = "\(line1)\n\(template.ar)"
        let enText = "\(line1)\n\(template.en)"

        return lang.isArabic ? arText + "\n\n" + enText : enText + "\n\n" + arText
    }

    // MARK: - منطق النشر (تبسيط لفكرتك: مرة مجانية + ٧ أيام)

    /// هذه الدالة تطبق منطق "مرة مجانية" بشكل مبسط:
    /// - باحث عن عمل: نتحقق إن ما عنده إعلان مجاني خلال آخر 30 يوم
    /// - صاحب عمل: نتحقق إن ما عنده إعلان مجاني سابق
    private func attemptPublishFree() {
        guard !isSaving, isFormValid, let template = selectedTemplate else { return }

        isSaving = true
        errorMessage = ""

        let phoneKey = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        // قاعدة التواريخ
        let now = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now

        var query = collection
            .whereField("ownerPhone", isEqualTo: phoneKey)
            .whereField("isFree", isEqualTo: true)

        if selectedRole == .lookingForJob {
            // باحث عن عمل: إعلان مجاني واحد كل 30 يوم
            query = query.whereField("createdAt", isGreaterThan: Timestamp(date: thirtyDaysAgo))
        }

        if selectedRole == .hiring {
            // صاحب عمل: أول إعلان مجاني فقط (لو وجد أي إعلان مجاني سابق نمنع)
            // هنا لا نضيف شرط التاريخ
        }

        query.getDocuments { snapshot, error in
            if let error {
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
                return
            }

            let count = snapshot?.documents.count ?? 0

            if self.selectedRole == .lookingForJob {
                if count > 0 {
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.errorMessage = self.lang.isArabic
                        ? "يمكنك نشر إعلان مجاني واحد فقط كل 30 يوم. يمكنك المحاولة لاحقاً أو استخدام إعلان مدفوع لاحقاً."
                        : "You can post only one free job ad every 30 days."
                        self.showErrorAlert = true
                    }
                    return
                }
            } else {
                // صاحب عمل
                if count > 0 {
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.errorMessage = self.lang.isArabic
                        ? "استخدمت الإعلان المجاني لصاحب العمل. الإعلانات القادمة ستكون مدفوعة."
                        : "You already used the free employer ad."
                        self.showErrorAlert = true
                    }
                    return
                }
            }

            // مسموح بالنشر المجاني
            self.saveAd(template: template, isFree: true)
        }
    }

    /// حفظ الإعلان في Firestore
    private func saveAd(template: JobTemplate, isFree: Bool) {
        guard let preview = previewText else {
            isSaving = false
            return
        }

        let now = Date()
        let expiresAt = now.addingTimeInterval(7 * 24 * 60 * 60) // ٧ أيام

        let data: [String: Any] = [
            "type": selectedRole.firestoreValue,
            "sector": selectedSector.rawValue,
            "templateId": template.id,
            "title": selectedRole == .hiring
                ? (lang.isArabic ? "إعلان توظيف" : "Hiring")
                : (lang.isArabic ? "طلب عمل" : "Looking for a job"),
            "details": preview,
            "city": city,
            "contact": phone,
            "ownerName": ownerName,
            "ownerPhone": phone,
            "isFree": isFree,
            "createdAt": Timestamp(date: now),
            "expiresAt": Timestamp(date: expiresAt)
        ]

        collection.addDocument(data: data) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                } else {
                    self.showSuccessAlert = true
                    self.resetForm()
                }
            }
        }
    }

    private func resetForm() {
        // نترك الاسم/المدينة/الهاتف كما هم، ونرجع القالب والقطاع للوضع الافتراضي
        selectedSector = .restaurants
        selectedRole = .lookingForJob
        selectedTemplateIndex = 0
        searchText = ""
    }
}
