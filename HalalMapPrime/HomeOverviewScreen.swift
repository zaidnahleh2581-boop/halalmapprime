//
//  HomeOverviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct HomeOverviewScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var router: AppRouter

    private let db = Firestore.firestore()
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // Jobs preview (from Firebase jobAds)
    @State private var previewJobs: [JobAd] = []
    @State private var jobsLoading: Bool = false
    @State private var tickerIndex: Int = 0

    // Distance (UI for now)
    @State private var radiusMiles: Int = 5
    @State private var showDistancePicker: Bool = false

    // Job alerts sheet
    @State private var showJobAlerts: Bool = false

    // Map sheet (category-based)
    @State private var showMapSheet: Bool = false
    @State private var mapStartingCategory: PlaceCategory? = nil

    // ✅ NEW: Prime Sponsored from Firestore (places/ad)
    @State private var primeSponsored: [SponsoredPlace] = []
    @State private var sponsoredLoading: Bool = false

    // Jobs ticker changes every 60 seconds
    private let tickerTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                // 1) Categories (visual)
                HomeCategoriesGrid { cat in
                    openMap(cat)
                }

                // 2) Core: Jobs (header row)
                jobsHeaderRow

                // 3) Core: One job ticker
                jobsTicker

                // ✅ 3.5) Events ticker (PAID ONLY) – opens Community
                HomeEventsTickerView()
                    .environmentObject(lang)
                    .environmentObject(router)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)

                // ✅ 4) PRIME Sponsored Ads (REAL from Firestore)
                primeSponsoredSection
            }
            .padding(.top, 8)
            .padding(.bottom, 22)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            fetchJobsPreview()
            fetchPrimeSponsored()
        }
        .onReceive(tickerTimer) { _ in
            guard !previewJobs.isEmpty else { return }
            tickerIndex = (tickerIndex + 1) % max(previewJobs.count, 1)
        }
        .sheet(isPresented: $showDistancePicker) { distanceSheet }
        .sheet(isPresented: $showJobAlerts) {
            JobAlertsSheet()
                .environmentObject(lang)
        }
        .sheet(isPresented: $showMapSheet) {
            MapScreen(startingCategory: mapStartingCategory, hideCategoryPicker: false)
                .environmentObject(lang)
                .environmentObject(router)
        }
    }

    // MARK: - Jobs Header (bell + distance + see all)

    private var jobsHeaderRow: some View {
        HStack(spacing: 10) {

            HStack(spacing: 8) {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(.primary)
                Text(L("وظائف قريبة منك", "Jobs near you"))
                    .font(.headline)
            }

            Spacer()

            // 🔔 Alerts
            Button {
                showJobAlerts = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.orange.opacity(0.95))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // 📍 Distance (visual now)
            Button { showDistancePicker = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text("\(radiusMiles) mi")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.95))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // ➜ Go to Jobs tab
            Button {
                router.selectedTab = 1
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L("عرض كل الوظائف", "See all jobs"))
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    // MARK: - Jobs Ticker (one card)

    private var jobsTicker: some View {
        VStack(alignment: .leading, spacing: 10) {

            if jobsLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(L("جاري تحميل الوظائف…", "Loading jobs…"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)

            } else if previewJobs.isEmpty {
                Text(L("لا توجد وظائف حالياً.", "No jobs right now."))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)

            } else {
                let ad = previewJobs[tickerIndex % max(previewJobs.count, 1)]

                Button {
                    router.selectedTab = 1
                } label: {
                    HStack(spacing: 12) {

                        ZStack {
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 42, height: 42)
                                .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)

                            Image(systemName: ad.type == .hiring ? "person.badge.plus" : "magnifyingglass")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(ad.type == .hiring ? Color.blue : Color.green)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(headlineForAd(ad))
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)

                            Text(ad.city.isEmpty ? L("قريب منك", "Near you") : ad.city)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Text(L("جديد", "New"))
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.75))
                            .clipShape(Capsule())

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
        }
    }

    private func headlineForAd(_ ad: JobAd) -> String {
        let cat = ad.category.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cat.isEmpty {
            return ad.type == .hiring
            ? L("مطلوب موظف • \(cat)", "Hiring • \(cat)")
            : L("أبحث عن عمل • \(cat)", "Seeking • \(cat)")
        } else {
            return ad.type == .hiring ? L("مطلوب موظف", "Hiring") : L("أبحث عن عمل", "Seeking")
        }
    }

    // MARK: - ✅ PRIME Sponsored (Firestore -> Home)

    private var primeSponsoredSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(L("إعلانات مميزة", "Sponsored"))
                    .font(.headline)
                Spacer()

                Button {
                    fetchPrimeSponsored()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

            if sponsoredLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(L("جاري تحميل الإعلانات…", "Loading sponsored…"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)

            } else if primeSponsored.isEmpty {
                Text(L("لا توجد إعلانات مميزة حالياً.", "No sponsored ads right now."))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)

            } else {
                // Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(primeSponsored) { item in
                            SponsoredPrimeCard(
                                langIsArabic: lang.isArabic,
                                item: item
                            ) {
                                // Action on tap:
                                // 1) افتح الخريطة لنفس الكاتيجوري (اختياري)
                                // 2) أو افتح تفاصيل المكان (لو عندك شاشة تفاصيل)
                                // الآن نخليه يفتح Tab "إعلانات" أو Map (اختيارك)
                                router.selectedTab = 2
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            .frame(width: 310)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                }
            }
        }
    }

    private func fetchPrimeSponsored() {
        sponsoredLoading = true

        db.collection("places")
            .whereField("ad.isActive", isEqualTo: true)
            .whereField("ad.plan", isEqualTo: "prime") // ✅ Prime فقط
            .order(by: "ad.priority", descending: true)
            .limit(to: 15)
            .getDocuments { snap, error in
                DispatchQueue.main.async {
                    self.sponsoredLoading = false

                    guard error == nil, let docs = snap?.documents else {
                        self.primeSponsored = []
                        return
                    }

                    self.primeSponsored = docs.compactMap { SponsoredPlace.from(doc: $0) }
                    self.primeSponsored.sort { ($0.adPriority) > ($1.adPriority) }
                }
            }
    }

    // MARK: - Map open (category-based)

    private func openMap(_ category: PlaceCategory) {
        mapStartingCategory = category
        showMapSheet = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Distance sheet

    private var distanceSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text(L("حدد نطاق المسافة", "Choose distance range"))
                    .font(.title3.weight(.semibold))
                    .padding(.top, 10)

                VStack(spacing: 10) {
                    ForEach([1, 3, 5, 10, 15, 25], id: \.self) { miles in
                        Button {
                            radiusMiles = miles
                            showDistancePicker = false
                        } label: {
                            HStack {
                                Text("\(miles) mi").font(.headline)
                                Spacer()
                                if miles == radiusMiles { Image(systemName: "checkmark.circle.fill") }
                            }
                            .padding()
                            .background(Color(.systemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle(L("المسافة", "Distance"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("تم", "Done")) { showDistancePicker = false }
                }
            }
        }
    }

    // MARK: - Firestore fetch (Job Ads)

    private func fetchJobsPreview() {
        jobsLoading = true

        db.collection("jobAds")
            .order(by: "createdAt", descending: true)
            .limit(to: 30)
            .getDocuments { snap, error in
                DispatchQueue.main.async {
                    self.jobsLoading = false

                    guard error == nil, let docs = snap?.documents else {
                        self.previewJobs = []
                        return
                    }

                    let all = docs.compactMap { JobAd(from: $0) }

                    self.previewJobs = all.sorted {
                        ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
                    }

                    self.tickerIndex = 0
                }
            }
    }
}

// MARK: - SponsoredPlace (Firestore-safe model)

private struct SponsoredPlace: Identifiable {
    let id: String

    // place basics
    let name: String
    let address: String
    let cityState: String
    let category: String
    let phone: String?
    let notes: String?

    // ad
    let adPlan: String
    let adPriority: Int
    let adIsActive: Bool

    // images (optional URLs)
    let imageUrls: [String]

    static func from(doc: QueryDocumentSnapshot) -> SponsoredPlace? {
        let data = doc.data()

        // basics
        let name = (data["name"] as? String) ?? "Business"
        let address = (data["address"] as? String) ?? ""
        let cityState = (data["cityState"] as? String) ?? ""
        let category = (data["category"] as? String) ?? ""
        let phone = data["phone"] as? String
        let notes = data["notes"] as? String

        // ad map
        let ad = (data["ad"] as? [String: Any]) ?? [:]
        let plan = (ad["plan"] as? String) ?? ""
        let isActive = (ad["isActive"] as? Bool) ?? false
        let priority = (ad["priority"] as? Int) ?? 0

        // optional images
        let urls = (ad["images"] as? [String]) ?? (data["images"] as? [String]) ?? []

        // must be prime + active
        // (نخليها حماية إضافية)
        guard isActive == true else { return nil }

        return SponsoredPlace(
            id: doc.documentID,
            name: name,
            address: address,
            cityState: cityState,
            category: category,
            phone: phone,
            notes: notes,
            adPlan: plan,
            adPriority: priority,
            adIsActive: isActive,
            imageUrls: urls
        )
    }
}

// MARK: - Prime Card UI

private struct SponsoredPrimeCard: View {
    let langIsArabic: Bool
    let item: SponsoredPlace
    let onTap: () -> Void

    private func L(_ ar: String, _ en: String) -> String { langIsArabic ? ar : en }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {

                // Images (if available)
                if !item.imageUrls.isEmpty {
                    TabView {
                        ForEach(item.imageUrls, id: \.self) { urlStr in
                            RemoteImage(urlString: urlStr)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.vertical, 4)
                        }
                    }
                    .frame(height: 165)
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                } else {
                    // fallback banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 120)

                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.yellow)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("إعلان مميز", "Prime Sponsored"))
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.secondary)

                                Text(item.name)
                                    .font(.headline.weight(.bold))
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                    }
                }

                // Title + city
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline.weight(.bold))
                            .lineLimit(1)

                        Text(displaySubline)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(L("مميز", "Prime"))
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.80))
                        .clipShape(Capsule())
                }

                // Offer / Notes (optional)
                if let notes = item.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }

                // Footer
                HStack {
                    Text(item.category.isEmpty ? L("نشاط تجاري", "Business") : item.category)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var displaySubline: String {
        if !item.cityState.isEmpty { return item.cityState }
        if !item.address.isEmpty { return item.address }
        return L("قريب منك", "Near you")
    }
}

// MARK: - Remote Image (simple)

private struct RemoteImage: View {
    let urlString: String

    var body: some View {
        if let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                        ProgressView()
                    }
                case .success(let img):
                    img.resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            }
        }
    }
}
