//
//  PaidAdPlanDetailView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import StoreKit

struct PaidAdPlanDetailView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let product: Product
    @ObservedObject var purchaseManager: PurchaseManager

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                header

                howItShowsCard

                featuresCard

                subscribeSection
            }
            .padding()
        }
        .navigationTitle(L("تفاصيل الخطة", "Plan Details"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
    }

    // MARK: - UI

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(product.displayName)
                .font(.title2.bold())

            Text(product.displayPrice)
                .font(.title3.weight(.semibold))

            Text(longDescription(for: product.id))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
    }

    private var howItShowsCard: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                Text(L("وين بيظهر إعلانك؟", "Where will your ad appear?"))
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(placements(for: product.id), id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text(line)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(cardBG)
    }

    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text(L("مميزات الخطة", "Plan features"))
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(features(for: product.id), id: \.self) { f in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(f)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // ✅ Optional note
            Text(L(
                "ملاحظة: بعد الدفع ستضيف تفاصيل إعلانك (صور + نص + بيانات الاتصال).",
                "Note: After purchase you will add your ad details (photos + text + contact info)."
            ))
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 6)
        }
        .padding()
        .background(cardBG)
    }

    private var subscribeSection: some View {
        VStack(spacing: 10) {

            Button {
                Task {
                    await purchaseManager.purchase(product)
                }
            } label: {
                HStack {
                    Spacer()
                    Text(L("اشترك الآن", "Subscribe now"))
                        .font(.headline)
                    Spacer()
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)

            Button {
                dismiss()
            } label: {
                Text(L("رجوع", "Back"))
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
        .padding(.top, 4)
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemGray6))
    }

    // MARK: - Content

    private func longDescription(for productID: String) -> String {
        switch productID {
        case "weekly_ad":
            return L(
                "خطة أسبوعية مناسبة للعروض السريعة. ظهور أعلى من العادي لمدة 7 أيام.",
                "Weekly plan for quick promos. Higher visibility for 7 days."
            )
        case "monthly_ad":
            return L(
                "خطة شهرية قوية. ظهور مميز لمدة 30 يوم مع أولوية أعلى في النتائج.",
                "Strong monthly plan. Featured visibility for 30 days with higher ranking."
            )
        case "prime_ad":
            return L(
                "Prime هو أقوى ظهور داخل التطبيق. أولوية قصوى + ظهور متكرر في أماكن مميزة.",
                "Prime gives maximum exposure. Top priority + repeated featured placements."
            )
        default:
            return ""
        }
    }

    private func placements(for productID: String) -> [String] {
        switch productID {
        case "weekly_ad":
            return [
                L("داخل قائمة النتائج: أعلى من الإضافات العادية.", "In results list: above normal listings."),
                L("على الخريطة: تمييز بسيط يساعد الناس تلاحظك.", "On the map: light highlight to get noticed."),
                L("ضمن التدوير (Rotation) حسب الفئة.", "In rotation by category.")
            ]
        case "monthly_ad":
            return [
                L("داخل قائمة النتائج: أولوية أعلى لمدة 30 يوم.", "In results list: higher priority for 30 days."),
                L("على الخريطة: تمييز أوضح من الأسبوعي.", "On the map: stronger highlight than weekly."),
                L("ظهور متكرر في التدوير (Rotation).", "More frequent rotation exposure.")
            ]
        case "prime_ad":
            return [
                L("أعلى النتائج دائماً (Top).", "Always at the top of results."),
                L("تمييز قوي على الخريطة + ظهور أكثر.", "Strong map highlight + more exposure."),
                L("إمكانية الظهور كبانر مميز داخل التطبيق.", "Potential featured banner placement inside the app.")
            ]
        default:
            return []
        }
    }

    private func features(for productID: String) -> [String] {
        switch productID {
        case "weekly_ad":
            return [
                L("مدة الإعلان: 7 أيام.", "Duration: 7 days."),
                L("أولوية ظهور: متوسطة.", "Visibility priority: medium."),
                L("مناسب للتجارب والعروض القصيرة.", "Great for testing and short promos.")
            ]
        case "monthly_ad":
            return [
                L("مدة الإعلان: 30 يوم.", "Duration: 30 days."),
                L("أولوية ظهور: عالية.", "Visibility priority: high."),
                L("أفضل قيمة مقابل المدة.", "Best value for longer exposure.")
            ]
        case "prime_ad":
            return [
                L("أولوية قصوى داخل التطبيق.", "Top priority inside the app."),
                L("أقوى ظهور على الخريطة والنتائج.", "Maximum visibility on map and results."),
                L("أنسب خيار للبراندات القوية.", "Best for strong brands.")
            ]
        default:
            return []
        }
    }
}
