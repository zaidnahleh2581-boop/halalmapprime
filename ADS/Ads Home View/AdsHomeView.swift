//
//  AdsHomeView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-15.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import UIKit

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var adsStore = AdsStore()

    // ✅ Verification Sheet
    @State private var showVerifySheet = false

    @State private var showFreeAdSheet = false
    @State private var showPaidSheet = false
    @State private var showFreeLimitAlert = false

    @State private var selectedAd: HMPAd? = nil
    @State private var showAdPreview: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    topButtonsRow

                    // ✅ NEW: Launch banner (official text)
                    launchBanner

                    profileCard

                    publicAdsSection
                    myAdsSection
                    expiredSection
                }
                .padding(.top, 10)
                .padding(.bottom, 22)
            }
            .navigationTitle(L("الإعلانات", "Ads"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { adsStore.load() }
        }
        .sheet(isPresented: $showPaidSheet) {
            NavigationStack {
                SelectAdPlanView()
                    .environmentObject(lang)
                    .environmentObject(adsStore)
            }
        }
        .sheet(isPresented: $showFreeAdSheet) {
            NavigationStack {
                CreateAdFormView(
                    planDisplayTitleAR: "إعلان مجاني (30 يوم)",
                    planDisplayTitleEN: "Free Ad (30 days)",
                    onSaved: { draft, imageDatas in
                        adsStore.createAdFromDraft(
                            draft: draft,
                            plan: .freeOnce,
                            imageDatas: imageDatas
                        )
                    }
                )
                .environmentObject(lang)
            }
        }

        // ✅ Verify Sheet
        .sheet(isPresented: $showVerifySheet) {
            NavigationStack {
                VerifyBusinessSheet(
                    langIsArabic: lang.isArabic,
                    defaultBusinessName: adsStore.profileBusinessName ?? "",
                    defaultCategory: "",
                    defaultAddress: ""
                )
            }
        }

        .sheet(isPresented: $showAdPreview) {
            if let ad = selectedAd {
                NavigationStack { AdPreviewScreen(langIsArabic: lang.isArabic, ad: ad) }
            }
        }
        .alert(L("تم استخدام الهدية المجانية", "Free gift already used"),
               isPresented: $showFreeLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(L("لقد استخدمت إعلانك المجاني مرة واحدة. الآن يمكنك اختيار خطة مدفوعة.",
                   "You already used your free ad once. Please choose a paid plan."))
        }
    }

    // MARK: - NEW Launch Banner

    private var launchBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(L("إطلاق النسخة الجديدة ✅", "New launch ✅"))
                        .font(.headline.weight(.bold))

                    Text(L(
                        "Halal Map Prime خدمة مجتمعية لدعم أصحاب المحلات. الإعلانات حالياً مجانية لفترة محدودة — جرّب الباقات الأسبوعية والشهرية والمميزة بدون دفع الآن.",
                        "Halal Map Prime is a community-first service to support local businesses. Ads are currently FREE for a limited time — try Weekly, Monthly, and Prime plans with no payment right now."
                    ))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                Label(L("مجاني لفترة محدودة", "Free for a limited time"), systemImage: "gift.fill")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.green.opacity(0.14))
                    .foregroundColor(.green)
                    .clipShape(Capsule())

                Label(L("الدفع لاحقاً", "Payment later"), systemImage: "creditcard.fill")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.orange.opacity(0.14))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())

                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
        .padding(.horizontal, 14)
    }

    // MARK: - Top Buttons

    private var topButtonsRow: some View {
        HStack(spacing: 10) {

            Button { showVerifySheet = true } label: {
                topPill(
                    title: L("توثيق المحل", "Get Verified"),
                    systemImage: "checkmark.seal.fill",
                    tint: .blue
                )
            }
            .buttonStyle(.plain)

            Button {
                if adsStore.canUseFreeGift {
                    showFreeAdSheet = true
                } else {
                    showFreeLimitAlert = true
                }
            } label: {
                topPill(title: L("إعلان مجاني", "Free Ad"),
                        systemImage: "gift.fill",
                        tint: .green)
                .opacity(adsStore.canUseFreeGift ? 1 : 0.35)
            }
            .buttonStyle(.plain)

            Button { showPaidSheet = true } label: {
                topPill(title: L("مدفوع", "Paid"),
                        systemImage: "creditcard.fill",
                        tint: .orange)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 3) {
                    Text(adsStore.profileBusinessName ?? L("حساب الإعلانات", "Ads Profile"))
                        .font(.headline.weight(.bold))

                    Text(adsStore.profilePhone ?? L("أنشئ إعلان لتظهر بياناتك هنا", "Create an ad to show your info here"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    adsStore.load()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                statChip(title: L("مجتمع", "Public"), value: "\(adsStore.activePublicAds.count)", tint: .blue)
                statChip(title: L("نشط", "My Active"), value: "\(adsStore.activeMyAds.count)", tint: .green)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 14)
    }

    // MARK: - Public Ads

    private var publicAdsSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("إعلانات المجتمع", "Community Ads"))
                .font(.title3.bold())
                .padding(.horizontal, 14)
                .padding(.top, 2)

            if adsStore.activePublicAds.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 140)
                    .overlay(Text(L("لا يوجد إعلانات عامة الآن", "No public ads yet")).foregroundStyle(.secondary))
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(adsStore.activePublicAds.prefix(25)) { ad in
                        Button {
                            selectedAd = ad
                            showAdPreview = true
                        } label: {
                            adsDashboardCard(ad)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
            }
        }
    }

    // MARK: - My Ads

    private var myAdsSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("إعلاناتك", "Your Ads"))
                .font(.title3.bold())
                .padding(.horizontal, 14)
                .padding(.top, 6)

            if adsStore.activeMyAds.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 140)
                    .overlay(Text(L("لا يوجد إعلانات نشطة بعد", "No active ads yet")).foregroundStyle(.secondary))
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(adsStore.activeMyAds) { ad in
                        Button {
                            selectedAd = ad
                            showAdPreview = true
                        } label: {
                            adsDashboardCard(ad)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
            }
        }
    }

    // MARK: - Expired

    private var expiredSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if adsStore.expiredMyAds.isEmpty { return AnyView(EmptyView()) }

            return AnyView(
                VStack(alignment: .leading, spacing: 10) {
                    Text(L("إعلانات منتهية", "Expired Ads"))
                        .font(.headline)
                        .padding(.horizontal, 14)
                        .padding(.top, 10)

                    VStack(spacing: 10) {
                        ForEach(adsStore.expiredMyAds.prefix(6)) { ad in
                            adsExpiredCard(ad)
                                .padding(.horizontal, 14)
                        }
                    }
                }
            )
        }
    }

    // MARK: - Cards

    private func adsDashboardCard(_ ad: HMPAd) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.businessName).font(.headline.weight(.bold)).lineLimit(1)
                    Text(ad.headline).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                planBadge(ad.plan)
            }

            // ✅ NEW: Prefer Storage URLs, fallback to legacy base64
            adCardImage(ad: ad)
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(ad.adText)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(ad.remainingText(langIsArabic: lang.isArabic))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 8)
    }

    @ViewBuilder
    private func adCardImage(ad: HMPAd) -> some View {
        // 1) Storage URL image
        if let firstURL = ad.imageURLs.first,
           let url = URL(string: firstURL), !firstURL.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder(title: L("تحميل الصورة...", "Loading image..."))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                case .failure:
                    // If URL fails, fallback to legacy if exists
                    if let legacy = ad.uiImages().first {
                        Image(uiImage: legacy)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    } else {
                        imagePlaceholder(title: L("فشل تحميل الصورة", "Failed to load"))
                    }
                @unknown default:
                    imagePlaceholder(title: L("تحميل الصورة...", "Loading image..."))
                }
            }
        }
        // 2) Legacy base64
        else if let legacy = ad.uiImages().first {
            Image(uiImage: legacy)
                .resizable()
                .scaledToFill()
                .clipped()
        }
        // 3) No image
        else {
            imagePlaceholder(title: L("لا توجد صورة", "No image"))
        }
    }

    private func imagePlaceholder(title: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .clipped()
    }

    private func adsExpiredCard(_ ad: HMPAd) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ad.businessName).font(.subheadline.weight(.bold)).lineLimit(1)
                Spacer()
                Text(L("منتهي", "Expired"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.9))
                    .clipShape(Capsule())
            }
            Text(ad.headline).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
    }

    // MARK: - UI Helpers

    private func planBadge(_ plan: HMPAdPlanKind) -> some View {
        let title: String
        let bg: Color

        switch plan {
        case .prime:
            title = "PRIME"; bg = .yellow.opacity(0.95)
        case .monthly:
            title = L("شهري", "MONTH"); bg = .blue.opacity(0.9)
        case .weekly:
            title = L("أسبوعي", "WEEK"); bg = .cyan.opacity(0.9)
        case .freeOnce:
            title = L("هدية", "GIFT"); bg = .green.opacity(0.9)
        }

        return Text(title)
            .font(.caption2.weight(.bold))
            .foregroundColor(plan == .prime ? .black : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(bg)
            .clipShape(Capsule())
    }

    private func topPill(title: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).font(.subheadline.weight(.semibold))
            Text(title).font(.subheadline.weight(.semibold)).lineLimit(1)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.15)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.35), lineWidth: 1))
    }

    private func statChip(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline.weight(.bold))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.12)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.22), lineWidth: 1))
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}

// MARK: - Verify Business Sheet (NEW)

private struct VerifyBusinessSheet: View {

    @Environment(\.dismiss) private var dismiss

    let langIsArabic: Bool
    let defaultBusinessName: String
    let defaultCategory: String
    let defaultAddress: String

    @State private var businessName: String = ""
    @State private var categoryName: String = ""
    @State private var addressLine: String = ""

    private func L(_ ar: String, _ en: String) -> String { langIsArabic ? ar : en }

    var body: some View {
        VStack(spacing: 14) {

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(.blue)
                .padding(.top, 8)

            Text(L("توثيق المحل", "Get Verified"))
                .font(.title2.bold())

            Text(L(
                "لتفعيل شارة (Verified) وزيادة ثقة العملاء، أرسل لنا مستند يثبت أن منتجاتك حلال (مثل فاتورة مورد/شهادة).",
                "To get a Verified badge and build customer trust, please send a document proving halal sourcing (invoice/certificate)."
            ))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)

            Form {
                Section(header: Text(L("بيانات المحل", "Business Details"))) {
                    TextField(L("اسم المحل", "Business name"), text: $businessName)
                    TextField(L("التصنيف", "Category"), text: $categoryName)
                    TextField(L("العنوان", "Address"), text: $addressLine)
                }

                Section {
                    Button {
                        WhatsAppHelper.openVerifyChat(
                            langIsArabic: langIsArabic,
                            placeName: businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? (langIsArabic ? "غير محدد" : "Not specified")
                                : businessName,
                            categoryName: categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? (langIsArabic ? "غير محدد" : "Not specified")
                                : categoryName,
                            addressLine: addressLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? (langIsArabic ? "غير محدد" : "Not specified")
                                : addressLine
                        )
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text(L("إرسال عبر واتساب", "Send via WhatsApp"))
                        }
                    }

                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text(L("إغلاق", "Close"))
                    }
                }
            }
        }
        .onAppear {
            businessName = defaultBusinessName
            categoryName = defaultCategory
            addressLine = defaultAddress
        }
    }
}
