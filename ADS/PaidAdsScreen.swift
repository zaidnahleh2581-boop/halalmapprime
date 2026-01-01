//
//  PaidAdsScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import StoreKit

struct PaidAdsScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var purchaseManager = PurchaseManager()

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
            content
                .navigationTitle(L("الإعلانات المدفوعة", "Paid Ads"))
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - CONTENT
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {

                headerSection

                if sortedProducts.isEmpty {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    ForEach(sortedProducts, id: \.id) { product in
                        productCard(for: product)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("روّج لمحلّك", "Promote Your Business"))
                .font(.title2.bold())

            Text(
                L(
                    "اختر الخطة المناسبة ليظهر إعلانك في أعلى النتائج والخريطة.",
                    "Choose a plan to feature your business at the top of results and map."
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Product Card
    private func productCard(for product: Product) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
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
                }
            }

            HStack {
                Text(product.displayPrice)
                    .font(.title3.bold())

                Spacer()

                Button {
                    Task {
                        await purchaseManager.purchase(product)
                    }
                } label: {
                    Text(L("اشتراك", "Subscribe"))
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
            return L(
                "إعلان فعّال لمدة 7 أيام",
                "Active ad for 7 days"
            )
        case "monthly_ad":
            return L(
                "إعلان مميّز لمدة 30 يوم",
                "Featured ad for 30 days"
            )
        case "prime_ad":
            return L(
                "أعلى أولوية + ظهور دائم",
                "Top priority + maximum exposure"
            )
        default:
            return ""
        }
    }
}
