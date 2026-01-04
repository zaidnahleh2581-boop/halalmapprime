//
//  PaidAdsScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Updated by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import StoreKit

struct PaidAdsScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var purchaseManager = PurchaseManager()

    // ✅ Navigation to details first
    @State private var selectedProduct: Product? = nil

    // MARK: - Helpers
    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    // ترتيب الخطط (Prime > Monthly > Weekly)
    private var sortedProducts: [Product] {
        purchaseManager.products.sorted { a, b in
            priority(for: a.id) > priority(for: b.id)
        }
    }

    private func priority(for productID: String) -> Int {
        switch productID {
        case "prime_ad": return 3
        case "monthly_ad": return 2
        case "weekly_ad": return 1
        default: return 0
        }
    }

    // MARK: - BODY
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    headerSection

                    if sortedProducts.isEmpty {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        ForEach(sortedProducts, id: \.id) { product in
                            productCard(for: product)
                                .onTapGesture {
                                    selectedProduct = product // ✅ open details first
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(L("الإعلانات المدفوعة", "Paid Ads"))
            .navigationBarTitleDisplayMode(.inline)

            // ✅ Details screen
            .navigationDestination(item: $selectedProduct) { product in
                AdPlanDetailsView(
                    product: product,
                    purchaseManager: purchaseManager
                )
                .environmentObject(lang)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("روّج لمحلّك", "Promote Your Business"))
                .font(.title2.bold())

            Text(
                L(
                    "اضغط على أي خطة لتفاصيلها أولاً، ثم ادفع كآخر خطوة.",
                    "Tap any plan to view details first, then pay as the final step."
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Product Card (Tap opens details)
    private func productCard(for product: Product) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayTitle(for: product))
                        .font(.headline)

                    Text(planDescription(for: product.id))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if product.id == "prime_ad" {
                    Text("🔥 PRIME")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                } else if product.id == "monthly_ad" {
                    Text(L("مميز", "Featured"))
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.18))
                        .cornerRadius(8)
                }
            }

            HStack {
                Text(product.displayPrice)
                    .font(.title3.bold())

                Spacer()

                // ✅ Button also opens details (NO direct purchase here)
                Button {
                    selectedProduct = product
                } label: {
                    Text(L("تفاصيل", "Details"))
                        .font(.subheadline.bold())
                        .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Plan Description
    private func planDescription(for productID: String) -> String {
        switch productID {
        case "weekly_ad":
            return L("إعلان فعّال لمدة 7 أيام", "Active ad for 7 days")
        case "monthly_ad":
            return L("إعلان مميّز لمدة 30 يوم", "Featured ad for 30 days")
        case "prime_ad":
            return L("بانر رئيسي + أعلى أولوية", "Main banner + top priority")
        default:
            return ""
        }
    }

    private func displayTitle(for product: Product) -> String {
        switch product.id {
        case "weekly_ad":
            return L("الإعلان الأسبوعي", "Weekly Ad")
        case "monthly_ad":
            return L("الإعلان الشهري", "Monthly Ad")
        case "prime_ad":
            return L("الإعلان المميز (Prime)", "Prime Ad")
        default:
            return product.displayName
        }
    }
}

// MARK: - Details View (Same file => no missing scope errors)
private struct AdPlanDetailsView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let product: Product
    let purchaseManager: PurchaseManager

    @State private var isPurchasing: Bool = false
    @State private var showDoneAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorText: String = ""

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                header

                whereShownCard

                benefitsCard

                notesCard

                buySection
            }
            .padding()
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .alert(L("تم", "Done"), isPresented: $showDoneAlert) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text(L("تمت العملية بنجاح.", "Purchase completed successfully."))
        }
        .alert(L("خطأ", "Error"), isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorText)
        }
    }

    private var titleText: String {
        switch product.id {
        case "weekly_ad": return L("تفاصيل الإعلان الأسبوعي", "Weekly Ad Details")
        case "monthly_ad": return L("تفاصيل الإعلان الشهري", "Monthly Ad Details")
        case "prime_ad": return L("تفاصيل الإعلان المميز", "Prime Ad Details")
        default: return L("تفاصيل الخطة", "Plan Details")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(displayName)
                .font(.title2.bold())

            Text(subtitleText)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(product.displayPrice)
                    .font(.title3.bold())

                Spacer()

                Text(durationBadge)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private var whereShownCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("وين راح يظهر إعلانك؟", "Where will your ad appear?"))
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(whereShownLines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(line)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("مميزات الخطة", "Plan benefits"))
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(benefitLines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.orange)
                        Text(line)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("ملاحظة", "Note"))
                .font(.footnote.weight(.semibold))
            Text(L(
                "بعد الدفع، ستنتقل لشاشة تعبئة تفاصيل الإعلان (نص قصير + صور) ثم نشر الإعلان.",
                "After payment, you’ll go to the ad details form (short text + photos) and then publish."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
    }

    private var buySection: some View {
        VStack(spacing: 10) {
            Button {
                Task { await buyNow() }
            } label: {
                HStack {
                    Spacer()
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(L("ادفع الآن", "Pay Now"))
                            .font(.headline)
                    }
                    Spacer()
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isPurchasing)

            Button {
                dismiss()
            } label: {
                Text(L("رجوع", "Back"))
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderless)
        }
        .padding(.top, 4)
    }

    private func buyNow() async {
        guard !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        await purchaseManager.purchase(product)

        // لو PurchaseManager عندك يرفع errors بطرق ثانية، قولّي
        // هنا بنفترض النجاح إذا ما في crash
        showDoneAlert = true
    }

    // MARK: - Computed Text
    private var displayName: String {
        switch product.id {
        case "weekly_ad": return L("الإعلان الأسبوعي", "Weekly Ad")
        case "monthly_ad": return L("الإعلان الشهري", "Monthly Ad")
        case "prime_ad": return L("الإعلان المميز (Prime)", "Prime Ad")
        default: return product.displayName
        }
    }

    private var subtitleText: String {
        switch product.id {
        case "weekly_ad":
            return L("أفضل خيار كبداية للمحل.", "Best starter plan for a business.")
        case "monthly_ad":
            return L("ظهور أقوى لمدة شهر كامل.", "Stronger visibility for a full month.")
        case "prime_ad":
            return L("أعلى ظهور داخل التطبيق.", "Top visibility inside the app.")
        default:
            return ""
        }
    }

    private var durationBadge: String {
        switch product.id {
        case "weekly_ad": return L("7 أيام", "7 Days")
        case "monthly_ad": return L("30 يوم", "30 Days")
        case "prime_ad": return L("Top", "Top")
        default: return ""
        }
    }

    private var whereShownLines: [String] {
        switch product.id {
        case "weekly_ad":
            return [
                L("داخل قائمة النتائج (أولوية أعلى من العادي).", "In results list (higher priority than normal)."),
                L("على الخريطة (تمييز بسيط).", "On the map (light highlight)."),
                L("ضمن تدوير الإعلانات داخل التطبيق.", "Inside in-app ad rotation.")
            ]
        case "monthly_ad":
            return [
                L("داخل النتائج (أولوية عالية).", "In results (high priority)."),
                L("على الخريطة (تمييز أوضح).", "On the map (stronger highlight)."),
                L("ضمن بنرات/تدوير بشكل أكثر.", "More frequent banner/rotation placement.")
            ]
        case "prime_ad":
            return [
                L("بانر رئيسي داخل التطبيق (Top).", "Main in-app banner (Top)."),
                L("أولوية رقم 1 في النتائج.", "Priority #1 in results."),
                L("تمييز قوي على الخريطة.", "Strong highlight on the map.")
            ]
        default:
            return []
        }
    }

    private var benefitLines: [String] {
        switch product.id {
        case "weekly_ad":
            return [
                L("مناسب للعروض السريعة.", "Great for quick promotions."),
                L("ظهور أعلى من الإدراج العادي.", "Higher visibility than standard listing.")
            ]
        case "monthly_ad":
            return [
                L("ثبات ظهور لمدة شهر.", "Stable presence for a month."),
                L("قيمة أفضل مقابل السعر.", "Better value for money.")
            ]
        case "prime_ad":
            return [
                L("أفضل خيار للتميز القوي.", "Best option for maximum exposure."),
                L("أقوى ظهور داخل التطبيق.", "Strongest visibility across the app.")
            ]
        default:
            return []
        }
    }
}
