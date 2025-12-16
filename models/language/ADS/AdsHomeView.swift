//
//  AdsHomeView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import SwiftUI

/// الشاشة الرئيسية لنظام الإعلانات داخل Halal Map Prime
struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var showFreeAdForm: Bool = false
    @State private var showPaidAdPlans: Bool = false
    @State private var showPrimeAdPlans: Bool = false
    @State private var showMyAds: Bool = false

    /// شاشة إعلانات الوظائف (أبحث عن عمل / أبحث عن موظف)
    @State private var showJobAds: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    headerSection
                    introSection
                    buttonsSection
                    footerNote
                }
                .padding()
            }
            .navigationTitle(lang.isArabic ? "الإعلانات" : "Ads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }

            // الشاشات الفرعية
            .sheet(isPresented: $showFreeAdForm) {
                FreeAdFormView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPaidAdPlans) {
                SelectAdPlanView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPrimeAdPlans) {
                SelectAdPlanView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showMyAds) {
                MyAdsView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showJobAds) {
                JobAdsBoardView()
                    .environmentObject(lang)
            }
        }
    }
}

// MARK: - Sections

private extension AdsHomeView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.isArabic ? "الإعلانات في Halal Map Prime" : "Ads in Halal Map Prime")
                .font(.title2.weight(.semibold))

            Text(lang.isArabic
                 ? "اختر نوع الإعلان الذي يناسب نشاطك التجاري أو خدمتك، وابدأ بالوصول إلى المجتمع المسلم في نيويورك ونيوجيرسي."
                 : "Choose the ad type that fits your business or service and reach the Muslim community in NYC & NJ.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var introSection: some View {
        Text(
            lang.isArabic
            ? "يمكنك بدء إعلان مجاني بسيط مرة واحدة لكل متجر، أو اختيار باقات مدفوعة يومية/أسبوعية/شهرية للحصول على ظهور أقوى في الخريطة والبنرات."
            : "You can start with a simple one-time free ad per store, or choose paid daily / weekly / monthly plans for stronger visibility in the map and banners."
        )
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    var buttonsSection: some View {
        VStack(spacing: 12) {

            adButton(
                titleAr: "إعلان مجاني (مرة واحدة)",
                titleEn: "Free basic ad (one time)",
                subtitleAr: "إعلان بسيط لمحلّك يظهر ضمن النتائج، متاح مرة واحدة لكل إيميل.",
                subtitleEn: "Simple listing for your place, available once per email.",
                background: Color.green
            ) {
                showFreeAdForm = true
            }

            adButton(
                titleAr: "إعلان مدفوع (يومي / أسبوعي / شهري)",
                titleEn: "Paid ad (daily / weekly / monthly)",
                subtitleAr: "اختر باقة مرنة لزيادة ظهور نشاطك في الخريطة والبنرات.",
                subtitleEn: "Choose a flexible plan to boost your visibility in map and banners.",
                background: Color.blue
            ) {
                showPaidAdPlans = true
            }

            adButton(
                titleAr: "Prime Ads (أعلى الخريطة)",
                titleEn: "Prime Ads (top banner)",
                subtitleAr: "أفضل ظهور ممكن: بانر مميز أعلى الصفحة الرئيسية وعلى الخريطة.",
                subtitleEn: "Maximum visibility: featured banner on top of the main map screen.",
                background: Color.orange
            ) {
                showPrimeAdPlans = true
            }

            adButton(
                titleAr: "إعلاناتي",
                titleEn: "My ads",
                subtitleAr: "إدارة الإعلانات التي قمت بإنشائها من قبل.",
                subtitleEn: "Manage the ads you have already created.",
                background: Color.purple
            ) {
                showMyAds = true
            }

            adButton(
                titleAr: "إعلانات وظائف (أبحث عن عمل / موظّف)",
                titleEn: "Job ads (looking for job / staff)",
                subtitleAr: "نموذج جاهز: أدخل اسمك والمدينة ونوع المكان، والنظام يجهّز نص الإعلان تلقائياً.",
                subtitleEn: "Structured template: enter your name, area, and place type, and we generate the ad text for you.",
                background: Color.brown
            ) {
                showJobAds = true
            }
        }
    }

    var footerNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.isArabic ? "ملاحظة مهمة" : "Policy note")
                .font(.footnote.weight(.semibold))

            Text(
                lang.isArabic
                ? "جميع الإعلانات يجب أن تكون حلال، قانونية داخل الولايات المتحدة، ومتوافقة مع سياسات Apple App Store وقواعد مجتمع Halal Map Prime."
                : "All ads must be halal, legal in the USA, and fully compliant with Apple App Store policies and Halal Map Prime community rules."
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.top, 12)
    }
}

// MARK: - Components

private extension AdsHomeView {

    func adButton(
        titleAr: String,
        titleEn: String,
        subtitleAr: String,
        subtitleEn: String,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button { action() } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.isArabic ? titleAr : titleEn)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(lang.isArabic ? subtitleAr : subtitleEn)
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(background.opacity(0.92))
            )
            .shadow(color: background.opacity(0.25), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
