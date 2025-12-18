//
//  MapScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/18/25
//
//  Home feed (Yelp-style): Search + Categories + Sponsored/Trending Ads (Firebase)
//

import SwiftUI

struct MapScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var viewModel = MapScreenViewModel()
    @ObservedObject private var adsStore = AdsStore.shared

    @State private var searchText: String = ""
    @State private var selectedPlace: Place? = nil

    @State private var showMoreCategories: Bool = false
    @State private var pushCategory: PlaceCategory? = nil

    private let topCategories: [PlaceCategory] = [.restaurant, .foodTruck, .market, .mosque]

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    header
                    searchBar
                    topCategoryBar

                    // ✅ Sponsored + Trending (Firebase realtime)
                    homeAdsSection
                        .padding(.horizontal)

                    // ✅ Search results only when typing
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        resultsList
                            .padding(.top, 6)
                    }
                }
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
            .navigationDestination(item: $pushCategory) { category in
                CategoryBrowseScreen(category: category)
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showMoreCategories) {
                MoreCategoriesSheet(
                    excluded: topCategories,
                    onSelect: { category in
                        showMoreCategories = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            pushCategory = category
                        }
                    }
                )
                .environmentObject(lang)
            }
            .task {
                // ✅ Start realtime listener once for this view lifecycle
                adsStore.startActiveListener()
            }
        }
    }
}

// MARK: - Header / Search / Categories / Results
private extension MapScreen {

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "moon.stars.fill")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.45))

                    Text(L("حلال ماب برايم", "Halal Map Prime"))
                        .font(.title3.bold())
                }

                Text(L("دليلك إلى كل ما هو حلال في مدينتك",
                       "Your guide to everything halal in your city"))
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(L("ابحث عن مكان حلال…", "Search for a halal place…"),
                      text: $searchText)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .onChange(of: searchText) { newValue in
                viewModel.filterBySearch(text: newValue)
            }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    viewModel.filterBySearch(text: "")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    func localizedCategoryName(_ category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return L("مطاعم", "Restaurants")
        case .foodTruck:  return L("فود ترك", "Food Trucks")
        case .market:     return L("أسواق", "Markets")
        case .mosque:     return L("مساجد", "Mosques")
        default:
            return category.displayName
        }
    }

    var topCategoryBar: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(L("التصنيفات", "Categories"))
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {

                    ForEach(topCategories) { category in
                        Button {
                            viewModel.searchNearby(category: category)
                            pushCategory = category
                        } label: {
                            HStack(spacing: 6) {
                                Text(category.emoji)
                                Text(localizedCategoryName(category))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }

                    Button { showMoreCategories = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "ellipsis.circle.fill")
                            Text(L("المزيد", "More"))
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
    }

    var resultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L("نتائج البحث", "Search results"))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(viewModel.filteredPlaces) { place in
                    Button { selectedPlace = place } label: {
                        PlaceRowView(place: place)
                    }
                    Divider().padding(.leading, 16)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - HOME ADS (Sponsored + Trending) — FirebaseAd ONLY
private extension MapScreen {

    private var activeAds: [FirebaseAd] {
        adsStore.activeAds.sorted { $0.createdAt > $1.createdAt }
    }

    private var sponsoredAds: [FirebaseAd] {
        activeAds.filter { $0.tier.lowercased() == "prime" || $0.tier.lowercased() == "standard" }
    }

    private var trendingAds: [FirebaseAd] {
        activeAds.filter { $0.tier.lowercased() == "free" }
    }

    var homeAdsSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Sponsored
            sectionTitle(L("Sponsored", "Sponsored"))
            if sponsoredAds.isEmpty {
                emptyBox(text: L("لا يوجد Sponsored بعد.", "No Sponsored ads yet."))
            } else {
                VStack(spacing: 12) {
                    ForEach(sponsoredAds) { ad in
                        adButtonCard(ad)
                    }
                }
            }

            // Trending
            sectionTitle(L("Trending", "Trending"))
            if trendingAds.isEmpty {
                emptyBox(text: L("لا يوجد Trending بعد.", "No Trending ads yet."))
            } else {
                VStack(spacing: 12) {
                    ForEach(trendingAds) { ad in
                        adButtonCard(ad)
                    }
                }
            }

            // If no ads at all
            if activeAds.isEmpty {
                emptyBox(text: L(
                    "لا يوجد إعلانات بعد. افتح تبويب الإعلانات وأضف إعلان (1–3 صور) وسيظهر هنا.",
                    "No ads yet. Open Ads tab and add an ad (1–3 photos) and it will appear here."
                ))
            }
        }
        .padding(.top, 4)
    }

    func sectionTitle(_ title: String) -> some View {
        HStack { Text(title).font(.headline); Spacer() }
    }

    func emptyBox(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }

    func adButtonCard(_ ad: FirebaseAd) -> some View {
        Button {
            // ✅ only open place if placeId matches existing Place
            if let pid = ad.placeId,
               let place = viewModel.places.first(where: { $0.id == pid }) {
                selectedPlace = place
            }
        } label: {
            firebaseAdCard(ad: ad)
        }
        .buttonStyle(.plain)
    }

    func firebaseAdCard(ad: FirebaseAd) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            FirebaseAdImagesCarousel(urls: ad.imageURLs)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {

                    Text(ad.businessName.isEmpty ? L("إعلان", "Ad") : ad.businessName)
                        .font(.subheadline.bold())
                        .lineLimit(1)

                    Text("\(ad.city), \(ad.state)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(badgeText(for: ad.tier))
                    .font(.caption2.bold())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.systemGray5), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    func badgeText(for tierString: String) -> String {
        switch tierString.lowercased() {
        case "prime":
            return lang.isArabic ? "⭐ برايم" : "⭐ Prime"
        case "standard":
            return lang.isArabic ? "💼 مدفوع" : "💼 Paid"
        default:
            return lang.isArabic ? "🆓 مجاني" : "🆓 Free"
        }
    }
}

// MARK: - Images Carousel (Firebase URLs)
private struct FirebaseAdImagesCarousel: View {

    let urls: [String]

    var body: some View {
        Group {
            if urls.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            } else if urls.count == 1, let u = URL(string: urls[0]) {
                FirebaseAdImage(url: u)
            } else {
                TabView {
                    ForEach(Array(urls.prefix(3)), id: \.self) { s in
                        if let u = URL(string: s) {
                            FirebaseAdImage(url: u)
                        } else {
                            RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
    }
}

private struct FirebaseAdImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.systemGray5)
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            case .failure:
                ZStack {
                    Color(.systemGray5)
                    Image(systemName: "xmark.octagon")
                        .foregroundColor(.secondary)
                }
            @unknown default:
                Color(.systemGray5)
            }
        }
    }
}
