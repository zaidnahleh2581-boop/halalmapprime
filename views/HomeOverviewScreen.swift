//
//  HomeOverviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct HomeOverviewScreen: View {

    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    enum HomeRoute: Hashable {
        case category(PlaceCategory)
    }

    @State private var path: [HomeRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 16) {

                    // ✅ Categories (3 primary + More)
                    HomeCategoriesGrid { category in
                        path.append(.category(category))
                    }
                    .environmentObject(lang)
                    .padding(.top, 8)

                    // ✅ Jobs preview (placeholder section)
                    jobsPreviewSection

                    // ✅ Featured Ads carousel (uses your demoBannerAds)
                    featuredAdsCarousel
                }
                .padding(.bottom, 18)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(L("الرئيسية", "Home"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .category(let category):
                    MapScreen(startingCategory: category, hideCategoryPicker: true)
                        .environmentObject(lang)
                        .navigationTitle(category.displayName)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

// MARK: - Sections
private extension HomeOverviewScreen {

    var jobsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("وظائف قربك اليوم", "Jobs Near You Today"))
                    .font(.headline)
                Spacer()
                // زر يروح لتب الوظائف (مستقبلاً نربطه)
                Text(L("عرض الكل", "See all"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text(L("• قريباً: سنعرض أحدث الوظائف المضافة حسب مدينتك.", "• Coming soon: we’ll show latest jobs based on your city."))
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Divider()

                Text(L("ضع إعلان وظيفة من تب (وظائف) وسيظهر هنا تلقائياً.", "Post a job from the (Jobs) tab and it will appear here automatically."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }

    var featuredAdsCarousel: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("إعلانات مميزة", "Featured Ads"))
                    .font(.headline)
                Spacer()
                Text(L("مزيد", "More"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(demoBannerAds) { ad in
                        adCard(ad)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
        }
    }

    func adCard(_ ad: BannerAd) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: ad.imageSystemName)
                    .font(.title3)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ad.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    Text(ad.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            Text(tagText(for: ad.categoryAudience))
                .font(.caption2.bold())
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.orange.opacity(0.15))
                .foregroundColor(.orange)
                .clipShape(Capsule())
        }
        .padding(14)
        .frame(width: 280, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    func tagText(for audience: AdAudience) -> String {
        switch audience {
        case .restaurants: return L("مطاعم / فود ترك", "Restaurants / Food Trucks")
        case .mosques:     return L("مساجد", "Mosques")
        case .shops:       return L("متاجر", "Shops")
        case .schools:     return L("مدارس", "Schools")
        }
    }
}
