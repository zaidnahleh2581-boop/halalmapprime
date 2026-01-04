//
//  AdsHomeView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Tabs
    enum TopTab: String, CaseIterable, Identifiable {
        case addLocation
        case myAds
        case privacy
        var id: String { rawValue }
    }

    @State private var selectedTab: TopTab = .addLocation

    // Sheets
    @State private var showAddLocationSheet = false
    @State private var showMyAdsSheet = false
    @State private var showPrivacySheet = false
    @State private var showPaidPlansSheet = false

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            topTabs

            Divider().opacity(0.20)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // ✅ تم حذف كرت "أضف عنوانك" من وسط الصفحة حسب طلبك

                    // ✅ Gift card (locked) — لا يفتح
                    lockedGiftCard

                    Text(L("إعلانات مدفوعة", "Paid Ads"))
                        .font(.title2.weight(.bold))
                        .padding(.top, 2)

                    paidCard(
                        title: L("إعلان مدفوع (باقات)", "Paid Ads (Packages)"),
                        subtitle: L("أسبوعي / شهري — ظهور أعلى على الخريطة والزيارات.", "Weekly / Monthly — higher visibility on map & visits."),
                        icon: "creditcard.fill",
                        tint: .cyan
                    ) {
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

        // ✅ Add Location Sheet (فتح فورم إضافة المكان)
        .sheet(isPresented: $showAddLocationSheet) {
            NavigationStack {
                // IMPORTANT: ما نضيف Close Toolbar هون عشان ما يصير "Close" مرتين
                AddHalalPlaceFormView(
                    preset: .normal,
                    gateMode: .none
                )
                .environmentObject(lang)
            }
        }

        // ✅ Paid Plans Sheet (مهم جداً)
        // بدل SelectAdPlanView (Coming soon) -> نفتح PaidAdsScreen الحقيقي
        .sheet(isPresented: $showPaidPlansSheet) {
            NavigationStack {
                PaidAdsScreen()
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

            // ✅ زر أزرق + أيقونة خريطة + "أضف عنوانك" (هو اللي يفتح الفورم)
            tabButton(
                title: L("أضف عنوانك", "Add Location"),
                systemImage: "map.fill",
                tint: .blue,
                isSelected: selectedTab == .addLocation
            ) {
                selectedTab = .addLocation
                showAddLocationSheet = true
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

    // MARK: - Cards

    // ✅ Gift card (locked) — جامد لا يفتح
    private var lockedGiftCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.green)
                Text(L("هدية مجانية", "Free Gift"))
                    .font(.headline)
                Spacer()
                Text(L("غير متاحة الآن", "Disabled"))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.18))
                    .clipShape(Capsule())
            }

            Text(L(
                "هذه الميزة حالياً مغلقة. استخدم (أضف عنوانك) أو الباقات المدفوعة.",
                "This feature is currently locked. Use Add Location or paid plans."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBG)
        .opacity(0.92)
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
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
            .background(cardBG)
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
}
