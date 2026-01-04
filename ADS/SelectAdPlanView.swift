//
//  SelectAdPlanView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

/// شاشة اختيار الباقة (UI فقط) → وبعدها نفتح PaidAdsScreen للمنتجات الحقيقية (StoreKit)
struct SelectAdPlanView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var showPaidAds = false

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                headerSection

                Text(L(
                    "اختر مدة الإعلان. بعد ما تختار، سننقلك لصفحة الدفع الرسمية عبر Apple (StoreKit).",
                    "Pick your ad duration. After selecting, we'll take you to Apple’s official payment screen (StoreKit)."
                ))
                .font(.subheadline)
                .foregroundColor(.secondary)

                VStack(spacing: 12) {
                    weeklyPlanCard
                    monthlyPlanCard
                    primePlanCard
                }
                .padding(.top, 4)

                comparisonSection
                footerNote
            }
            .padding()
        }
        .navigationTitle(L("اختيار الباقة", "Choose a Plan"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
        .sheet(isPresented: $showPaidAds) {
            NavigationStack {
                PaidAdsScreen()
                    .environmentObject(lang)
            }
        }
    }
}

// MARK: - UI Components
private extension SelectAdPlanView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("اختر باقة الإعلان", "Select Your Ad Plan"))
                .font(.title2.bold())

            Text(L(
                "كل باقة تختلف في مدة الظهور والأولوية داخل التطبيق.",
                "Each plan differs by duration and priority inside the app."
            ))
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    var weeklyPlanCard: some View {
        planCard(
            titleAR: "إعلان أسبوعي (الأكثر اختياراً)",
            titleEN: "Weekly Ad (Most popular)",
            subtitleAR: "7 أيام • أولوية متوسطة",
            subtitleEN: "7 days • Medium priority",
            descriptionAR: "يظهر إعلانك في أماكن الإعلانات داخل التطبيق + ترتيب أعلى في النتائج.",
            descriptionEN: "Your ad appears in the app’s ad spots + higher ranking in results.",
            bulletsAR: [
                "مناسب للمطاعم والخدمات.",
                "ظهور ثابت لمدة أسبوع.",
                "أفضل توازن بين السعر والنتيجة."
            ],
            bulletsEN: [
                "Great for restaurants & services.",
                "Steady visibility for a week.",
                "Best balance of cost and outcome."
            ],
            accent: .blue
        ) {
            showPaidAds = true
        }
    }

    var monthlyPlanCard: some View {
        planCard(
            titleAR: "إعلان شهري (مميز)",
            titleEN: "Monthly Ad (Premium)",
            subtitleAR: "30 يوم • أولوية عالية",
            subtitleEN: "30 days • High priority",
            descriptionAR: "ظهور أقوى لمدة شهر مع أولوية أعلى في التدوير وترتيب النتائج.",
            descriptionEN: "Stronger visibility for a month with higher rotation priority and ranking.",
            bulletsAR: [
                "أفضل خيار لثبات الظهور.",
                "أولوية أعلى من الأسبوعي.",
                "مناسب للعروض الطويلة."
            ],
            bulletsEN: [
                "Best for consistent presence.",
                "Higher priority than weekly.",
                "Great for longer promos."
            ],
            accent: .green
        ) {
            showPaidAds = true
        }
    }

    var primePlanCard: some View {
        planCard(
            titleAR: "Prime Ads (أفضل ظهور)",
            titleEN: "Prime Ads (Top visibility)",
            subtitleAR: "أعلى أولوية • ظهور أقوى",
            subtitleEN: "Top priority • Max exposure",
            descriptionAR: "أقوى خطة: بانر مميز + ظهور أعلى داخل التطبيق.",
            descriptionEN: "Strongest plan: featured banner + top visibility inside the app.",
            bulletsAR: [
                "أولوية رقم 1.",
                "أفضل ظهور داخل التطبيق.",
                "مناسب للبراندات القوية."
            ],
            bulletsEN: [
                "Priority #1.",
                "Maximum in-app exposure.",
                "Great for strong brands."
            ],
            accent: .orange
        ) {
            showPaidAds = true
        }
    }

    func planCard(
        titleAR: String,
        titleEN: String,
        subtitleAR: String,
        subtitleEN: String,
        descriptionAR: String,
        descriptionEN: String,
        bulletsAR: [String],
        bulletsEN: [String],
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {

        let bullets = lang.isArabic ? bulletsAR : bulletsEN

        return Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lang.isArabic ? titleAR : titleEN)
                            .font(.headline)

                        Text(lang.isArabic ? subtitleAR : subtitleEN)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(accent)
                                .imageScale(.medium)
                        )
                }

                Text(lang.isArabic ? descriptionAR : descriptionEN)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                            Text(bullet)
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }

                Text(L("تابع للدفع", "Continue to payment"))
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accent)
                    )
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }

    var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("مقارنة سريعة", "Quick comparison"))
                .font(.headline)

            VStack(spacing: 6) {
                comparisonRow(
                    label: L("المدة", "Duration"),
                    weekly: L("7 أيام", "7 days"),
                    monthly: L("30 يوم", "30 days"),
                    prime: L("أعلى", "Top")
                )

                comparisonRow(
                    label: L("قوة الظهور", "Visibility"),
                    weekly: "⭐⭐",
                    monthly: "⭐⭐⭐",
                    prime: "⭐⭐⭐⭐"
                )

                comparisonRow(
                    label: L("الأولوية", "Priority"),
                    weekly: L("متوسطة", "Medium"),
                    monthly: L("عالية", "High"),
                    prime: L("الأعلى", "Top")
                )
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.top, 8)
    }

    func comparisonRow(label: String, weekly: String, monthly: String, prime: String) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(weekly)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(monthly)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(prime)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    var footerNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L("ملاحظة مهمة", "Important note"))
                .font(.footnote.weight(.semibold))

            Text(L(
                "الدفع يتم عبر Apple In-App Purchase. يمكنك إدارة الاشتراك من إعدادات App Store.",
                "Payments are handled via Apple In-App Purchase. You can manage subscriptions from App Store settings."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
}

// MARK: - Preview
struct SelectAdPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectAdPlanView()
                .environmentObject(LanguageManager())
        }
    }
}
