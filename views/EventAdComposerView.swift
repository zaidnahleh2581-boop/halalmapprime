//
//  EventAdComposerView.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import SwiftUI

struct EventAdComposerView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // بيانات الفعالية
    @State private var city: String = ""
    @State private var placeName: String = ""
    @State private var eventDate: Date = Date()
    @State private var contact: String = ""

    // نوع الحدث / قالب جاهز
    @State private var selectedTemplateIndex: Int = 0

    @State private var isSaving: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    struct EventTemplate: Identifiable {
        let id: Int
        let titleAr: String
        let titleEn: String
        let descriptionAr: String
        let descriptionEn: String
    }

    // قوالب فعّاليات (تقدر نزيدها بعدين)
    private let templates: [EventTemplate] = [
        .init(
            id: 0,
            titleAr: "إفطار رمضاني",
            titleEn: "Ramadan iftar",
            descriptionAr: "دعوة لحضور إفطار رمضاني جماعي.",
            descriptionEn: "Invitation to a community Ramadan iftar."
        ),
        .init(
            id: 1,
            titleAr: "بازار رمضاني",
            titleEn: "Ramadan bazaar",
            descriptionAr: "بازار رمضاني لعرض المنتجات والخدمات.",
            descriptionEn: "Ramadan bazaar for products and services."
        ),
        .init(
            id: 2,
            titleAr: "محاضرة دينية",
            titleEn: "Religious lecture",
            descriptionAr: "محاضرة دينية مفتوحة للجميع.",
            descriptionEn: "Open religious lecture for the community."
        ),
        .init(
            id: 3,
            titleAr: "نشاط للأطفال",
            titleEn: "Kids activity day",
            descriptionAr: "يوم نشاطات ترفيهية للأطفال.",
            descriptionEn: "Fun activity day for kids."
        ),
        .init(
            id: 4,
            titleAr: "حملة خيرية",
            titleEn: "Charity event",
            descriptionAr: "حملة خيرية لدعم العائلات المحتاجة.",
            descriptionEn: "Charity event to support families in need."
        )
    ]

    private var minDate: Date {
        Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date()
    }

    private var selectedTemplate: EventTemplate {
        templates[min(selectedTemplateIndex, templates.count - 1)]
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }

    private var isFormValid: Bool {
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !contact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text(lang.isArabic ? "نوع الفعالية" : "Event type")) {
                    Picker(lang.isArabic ? "اختيار الفعالية" : "Select event",
                           selection: $selectedTemplateIndex) {
                        ForEach(Array(templates.enumerated()), id: \.offset) { index, t in
                            Text(lang.isArabic ? t.titleAr : t.titleEn)
                                .tag(index)
                        }
                    }
                }

                Section(header: Text(lang.isArabic ? "المكان والوقت" : "Place & time")) {
                    TextField(lang.isArabic ? "المدينة / المنطقة" : "City / area",
                              text: $city)

                    TextField(lang.isArabic ? "اسم المكان (مسجد / سنتر / قاعة)" : "Place name",
                              text: $placeName)

                    DatePicker(
                        lang.isArabic ? "تاريخ الفعالية" : "Event date",
                        selection: $eventDate,
                        in: minDate...,
                        displayedComponents: .date
                    )
                }

                Section(header: Text(lang.isArabic ? "التواصل" : "Contact")) {
                    TextField(
                        lang.isArabic ? "رقم الهاتف أو وسيلة التواصل" : "Phone / contact",
                        text: $contact
                    )
                    .keyboardType(.numbersAndPunctuation)
                }

                // معاينة النص النهائي
                Section(header: Text(lang.isArabic ? "معاينة الإعلان" : "Preview")) {
                    Text(previewText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                Section {
                    Button {
                        saveEvent()
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text(lang.isArabic ? "نشر الفعالية" : "Publish event")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .navigationTitle(lang.isArabic ? "إعلان فعالية" : "Event ad")
            .navigationBarTitleDisplayMode(.inline)
            .alert(lang.isArabic ? "تم الحفظ" : "Saved",
                   isPresented: $showSuccessAlert) {
                Button(lang.isArabic ? "إغلاق" : "Close") {
                    dismiss()
                }
            } message: {
                Text(lang.isArabic ?
                     "تم إرسال إعلان الفعالية، وسيظهر في لوحة الفعاليات." :
                     "Your event was saved and will appear in the events board.")
            }
            .alert(lang.isArabic ? "خطأ" : "Error",
                   isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Preview

    private var previewText: String {
        let t = selectedTemplate
        let dateString = dateFormatter.string(from: eventDate)

        let ar = """
        \(t.titleAr)
        المكان: \(placeName) – \(city)
        التاريخ: \(dateString)
        للتواصل: \(contact)
        \(t.descriptionAr)
        """

        let en = """
        \(t.titleEn)
        Place: \(placeName) – \(city)
        Date: \(dateString)
        Contact: \(contact)
        \(t.descriptionEn)
        """

        return lang.isArabic ? ar + "\n\n" + en : en + "\n\n" + ar
    }

    // MARK: - Actions

    private func saveEvent() {
        guard !isSaving, isFormValid else { return }
        isSaving = true
        errorMessage = ""

        let t = selectedTemplate
        let finalTitle = lang.isArabic ? t.titleAr : t.titleEn
        let finalDescription = previewText   // نفس نص المعاينة

        EventAdsService.shared.publish(
            title: finalTitle,
            city: city,
            placeName: placeName,
            eventDate: eventDate,
            description: finalDescription,
            contact: contact
        ) { error in
            DispatchQueue.main.async {
                self.isSaving = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                } else {
                    self.showSuccessAlert = true
                    self.clearForm()
                }
            }
        }
    }

    private func clearForm() {
        city = ""
        placeName = ""
        contact = ""
        eventDate = Date()
        selectedTemplateIndex = 0
    }
}
