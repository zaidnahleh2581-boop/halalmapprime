import SwiftUI
import MapKit

struct MapScreen: View {
    // MARK: - State / Environment

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var viewModel = MapScreenViewModel()

    // 🔹 ViewModel للبنرات المدفوعة (paidAdOrders → MapPaidAdsViewModel)
    @StateObject private var paidBannerVM = MapPaidAdsViewModel()

    @State private var selectedCategory: PlaceCategory? = nil
    @State private var searchText: String = ""
    @State private var showResults: Bool = true
    @State private var selectedPlace: Place? = nil

    @State private var showCategoriesRow: Bool = false // إظهار / إخفاء صف الكاتيجوري

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    // HEADER + SEARCH + CATEGORIES
                    header
                    searchBar
                    categoryFilters

                    // 🔺 إعلان Prime / Paid أعلى الصفحة
                    topAdsSection

                    // 🗺 الخريطة (أكبر عشان تبان أكثر)
                    mapView

                    // 🔻 شريط متحرّك صغير لــ Prime Highlights (مطاعم/مساجد/تموين)
                    primeHighlightsCarousel
                        .padding(.horizontal)

                    // قائمة النتائج
                    if showResults {
                        resultsList
                    }
                }
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
        }
    }
}

// MARK: - Helper for localization
private extension MapScreen {
    func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }
}

// MARK: - Header / Search / Categories / Map / Results

private extension MapScreen {

    // هيدر بهوية إسلامية بسيطة (هلال + سطر تعريفي)
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

                Text(
                    L(
                        "دليلك إلى كل ما هو حلال في مدينتك",
                        "Your guide to everything halal in your city"
                    )
                )
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

            TextField(
                L("ابحث عن مكان حلال…", "Search for a halal place…"),
                text: $searchText
            )
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

    // ✅ زر "التصنيفات" + صف الكاتيجوري تحتها
    var categoryFilters: some View {
        VStack(spacing: 6) {

            // زر واحد للتصنيفات
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    showCategoriesRow.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .imageScale(.medium)

                    Text(L("التصنيفات", "Categories"))
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    Image(systemName: showCategoriesRow ? "chevron.up" : "chevron.down")
                        .imageScale(.small)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    Capsule()
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            // صف الكاتيجوري يظهر فقط عند الفتح
            if showCategoriesRow {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(PlaceCategory.allCases) { category in
                            Button {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                    viewModel.searchNearby(category: nil)
                                } else {
                                    selectedCategory = category
                                    viewModel.searchNearby(category: category)
                                }
                                viewModel.filterBySearch(text: searchText)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(category.displayName)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    (selectedCategory == category)
                                    ? category.mapColor.opacity(0.25)
                                    : Color(.systemGray6)
                                )
                                .foregroundColor(
                                    (selectedCategory == category)
                                    ? .primary
                                    : .secondary
                                )
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    var mapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.filteredPlaces
        ) { place in
            MapAnnotation(coordinate: place.coordinate) {
                VStack(spacing: 2) {
                    Text(place.category.emoji)
                        .font(.system(size: 20))
                    Circle()
                        .fill(place.category.mapColor)
                        .frame(width: 10, height: 10)
                }
                .onTapGesture {
                    selectedPlace = place
                    viewModel.focus(on: place)
                }
            }
        }
        .frame(height: 280) // أكبر من قبل عشان الماب تبان أكثر
        .cornerRadius(16)
        .padding(.horizontal)
    }

    /// قائمة النتائج بدون List عشان ما يصير تعارض Scroll
    var resultsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredPlaces) { place in
                Button {
                    selectedPlace = place
                    viewModel.focus(on: place)
                } label: {
                    PlaceRowView(place: place)
                }

                Divider()
                    .padding(.leading, 16)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - ADS / PRIME SECTIONS

private extension MapScreen {

    /// 🔺 أعلى الصفحة: لو في إعلانات مدفوعة → نعرض البنر المدفوع
    /// لو مافي → نرجع للبنر الإسلامي الثابت
    var topAdsSection: some View {
        Group {
            if !paidBannerVM.activeAds.isEmpty {
                // بنر الإعلانات المدفوعة (Paid) – جاي من MapPaidBannerView
                MapPaidBannerView(viewModel: paidBannerVM)
                    .environmentObject(lang)
            } else {
                // البنر القديم الثابت (Prime Banner) كـ Fallback
                bigPrimeBanner(
                    titleEN: "Featured halal prime ad",
                    titleAR: "إعلان حلال مميز",
                    subtitleEN: "Top visibility for your halal business in NYC & NJ.",
                    subtitleAR: "أعلى ظهور لنشاطك الحلال في نيويورك ونيوجيرسي.",
                    tagTextEN: "PRIME • HALAL",
                    tagTextAR: "إعلان حلال • PRIME",
                    logoName: nil
                )
                .padding(.horizontal)
            }
        }
    }

    // 🔻 شريط متحرك صغير أسفل الخريطة (Prime Highlights)
    var primeHighlightsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                smallPrimeBanner(
                    icon: "fork.knife",
                    title: L("مطاعم حلال", "Halal Restaurants"),
                    subtitle: L("أفضل الخيارات القريبة", "Top nearby picks")
                )
                smallPrimeBanner(
                    icon: "mappin.and.ellipse",
                    title: L("مساجد / Masjid", "Mosques / Masjid"),
                    subtitle: L("الصلاة والجمعة", "Prayer & Jumu’ah")
                )
                smallPrimeBanner(
                    icon: "cart.fill",
                    title: L("محلات التموين", "Groceries"),
                    subtitle: L("منتجات حلال طازجة", "Fresh halal products")
                )
            }
            .padding(.vertical, 4)
        }
    }

    // مكوّن إعلان Prime كبير – بألوان إسلامية
    func bigPrimeBanner(
        titleEN: String,
        titleAR: String,
        subtitleEN: String,
        subtitleAR: String,
        tagTextEN: String,
        tagTextAR: String,
        logoName: String?
    ) -> some View {
        let title = L(titleAR, titleEN)
        let subtitle1 = L(subtitleAR, subtitleEN)
        let tagText = L(tagTextAR, tagTextEN)

        return ZStack {
            // Gradient إسلامي: أخضر غامق → تركواز
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.30, blue: 0.23),
                    Color(red: 0.00, green: 0.55, blue: 0.50)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                .blendMode(.overlay)

            HStack(spacing: 14) {
                if let logoName = logoName, !logoName.isEmpty {
                    Image(logoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 4)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.black.opacity(0.2))
                        Image(systemName: "moon.stars.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .frame(width: 52, height: 52)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(subtitle1)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)

                    Text(tagText)
                        .font(.caption2.bold())
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.22))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding(14)
        }
        .frame(height: 120)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
    }

    // مكوّن البانر الصغير (Prime box) لشريط الكاروسيل
    func smallPrimeBanner(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(L("Prime • Halal", "Prime • Halal"))
                .font(.caption2)
                .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.45))
        }
        .padding(10)
        .frame(width: 180, alignment: .leading) // عرض ثابت عشان يتحرك بالشريط
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
