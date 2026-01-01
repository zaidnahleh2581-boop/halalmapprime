//
//  AdsHomeView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Tabs
    enum TopTab: String, CaseIterable, Identifiable {
        case freeGift
        case myAds
        case privacy
        var id: String { rawValue }
    }

    @State private var selectedTab: TopTab = .freeGift

    // Sheets
    @State private var showGiftAddPlaceSheet = false
    @State private var showMyAdsSheet = false
    @State private var showPrivacySheet = false
    @State private var showPaidPlansSheet = false

    // ✅ UI hide after used on THIS device (real protection is server-side gate)
    @AppStorage("ads_lifetime_gift_used_local") private var giftUsedLocal: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            topTabs

            Divider().opacity(0.20)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    if !giftUsedLocal {
                        giftCard
                    } else {
                        usedGiftCard
                    }

                    Text(L("إعلانات مدفوعة", "Paid Ads"))
                        .font(.title2.weight(.bold))
                        .padding(.top, 2)

                    paidCard(
                        title: L("إعلان مدفوع (باقات)", "Paid Ads (Packages)"),
                        subtitle: L("أسبوعي / شهري — ظهور أعلى على الخريطة والزيارات.", "Weekly / Monthly — higher visibility on map & visits."),
                        icon: "creditcard.fill",
                        tint: .cyan
                    ) {
                        // open plans UI (no monetization dependency)
                        showPaidPlansSheet = true
                    }

                    paidCard(
                        title: L("Prime Ads (أفضل ظهور)", "Prime Ads (Top Visibility)"),
                        subtitle: L("بانر مميز + أولوية أعلى داخل التطبيق.", "Featured banner + higher priority inside the app."),
                        icon: "sparkles",
                        tint: .orange
                    ) {
                        showPaidPlansSheet = true
                    }

                    Spacer(minLength: 18)
                }
                .padding()
            }
        }
        .navigationTitle(L("الإعلانات", "Ads"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
            }
        }

        // ✅ Gift Add Place Sheet (Lifetime gift)
        .sheet(isPresented: $showGiftAddPlaceSheet) {
            NavigationStack {
                AddHalalPlaceFormView(
                    preset: .normal,
                    gateMode: .adsLifetimeGift,
                    onGiftConsumedOrAttempted: {
                        // hide gift button locally immediately
                        giftUsedLocal = true
                    },
                    onNeedPaidUpgrade: {
                        // if blocked, go to paid plans
                        showPaidPlansSheet = true
                    }
                )
                .environmentObject(lang)
                .navigationTitle(L("هدية مرة واحدة", "One-time Gift"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(L("إغلاق", "Close")) {
                            showGiftAddPlaceSheet = false
                        }
                    }
                }
            }
        }

        // ✅ Paid Plans Sheet (SelectAdPlanView)
        .sheet(isPresented: $showPaidPlansSheet) {
            NavigationStack {
                SelectAdPlanView()
                    .environmentObject(lang)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) {
                                showPaidPlansSheet = false
                            }
                        }
                    }
            }
        }

        // ✅ My Ads Sheet
        .sheet(isPresented: $showMyAdsSheet) {
            NavigationStack {
                MyAdsView()
                    .environmentObject(lang)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) {
                                showMyAdsSheet = false
                            }
                        }
                    }
            }
        }

        // ✅ Privacy Sheet
        .sheet(isPresented: $showPrivacySheet) {
            NavigationStack {
                AdsPrivacyView()
                    .environmentObject(lang)
                    .navigationTitle(L("الخصوصية والأمان", "Privacy & Safety"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) {
                                showPrivacySheet = false
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Top Tabs

    private var topTabs: some View {
        HStack(spacing: 10) {
            tabButton(
                title: L("هدية مجانية", "Free Gift"),
                systemImage: "gift.fill",
                tint: .green,
                isSelected: selectedTab == .freeGift
            ) {
                selectedTab = .freeGift
                if !giftUsedLocal {
                    showGiftAddPlaceSheet = true
                }
            }

            tabButton(
                title: L("إعلاناتي", "My Ads"),
                systemImage: "doc.text.magnifyingglass",
                tint: .purple,
                isSelected: selectedTab == .myAds
            ) {
                selectedTab = .myAds
                showMyAdsSheet = true
            }

            tabButton(
                title: L("الخصوصية\nوالأمان", "Privacy\n& Safety"),
                systemImage: "lock.fill",
                tint: .gray,
                isSelected: selectedTab == .privacy
            ) {
                selectedTab = .privacy
                showPrivacySheet = true
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Gift Cards

    private var giftCard: some View {
        Button {
            showGiftAddPlaceSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.green)
                    Text(L("هدية من التطبيق (مرة واحدة)", "App Gift (One-time)"))
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }

                Text(L(
                    "أضف محلك على الخريطة مجانًا مرة واحدة بالعُمر. إذا تم استخدام الهدية لنفس المحل سابقًا سيتم منعها تلقائيًا.",
                    "Add your place to the map for free once in a lifetime. If this place already used the gift, it will be blocked automatically."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }

    private var usedGiftCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text(L("تم استخدام الهدية", "Gift Used"))
                    .font(.headline)
                Spacer()
            }

            Text(L(
                "هدية الإضافة المجانية تم استخدامها. يمكنك الآن اختيار باقة مدفوعة لترويج نشاطك.",
                "The free gift was used. You can now choose a paid plan to boost your business."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)

            Button {
                showPaidPlansSheet = true
            } label: {
                Text(L("عرض الباقات المدفوعة", "View paid plans"))
                    .font(.footnote.weight(.semibold))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.92))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - UI

    private func paidCard(title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.18))
                    .foregroundColor(tint)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }

    private func tabButton(title: String, systemImage: String, tint: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.92) : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : (tint == .gray ? .primary : tint))
        }
        .buttonStyle(.plain)
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}
