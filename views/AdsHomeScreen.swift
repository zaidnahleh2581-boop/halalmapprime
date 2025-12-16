//
//  AdsHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25
//
//  Paid & Free Ads Hub (Yelp-style)
//

import SwiftUI

struct AdsHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @ObservedObject private var adsStore = AdsStore.shared

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    headerSection

                    if adsStore.activeAdsSorted().isEmpty {
                        emptyState
                    } else {
                        adsList
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle(L("الإعلانات المدفوعة", "Paid Ads"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sections

private extension AdsHomeScreen {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("روّج لمكانك", "Promote your place"))
                .font(.title2.bold())

            Text(
                L(
                    "اعرض مطعمك أو محلك أمام آلاف المستخدمين داخل حلال ماب برايم.",
                    "Show your restaurant or store to thousands of users on Halal Map Prime."
                )
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }

    var adsList: some View {
        VStack(spacing: 14) {
            ForEach(adsStore.activeAdsSorted()) { ad in
                AdCard(ad: ad)
            }
        }
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("لا يوجد إعلانات حالياً", "No ads yet"))
                .font(.headline)

            Text(
                L(
                    "ابدأ بإضافة إعلان مجاني، وسيظهر هنا مباشرة.",
                    "Start by adding a free ad and it will appear here instantly."
                )
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Ad Card

private struct AdCard: View {

    let ad: Ad

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            AdImagesCarousel(paths: ad.imagePaths)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.placeId)
                        .font(.subheadline.bold())

                    Text(ad.tier == .prime ? "⭐ Prime Ad" :
                         ad.tier == .standard ? "💼 Paid Ad" : "🆓 Free Ad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        )
    }
}

// MARK: - Images Carousel

private struct AdImagesCarousel: View {

    let paths: [String]

    var body: some View {
        TabView {
            ForEach(paths, id: \.self) { name in
                if let img = loadLocalImage(named: name) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(.systemGray5)
                }
            }
        }
        .tabViewStyle(.page)
    }

    private func loadLocalImage(named filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
}
