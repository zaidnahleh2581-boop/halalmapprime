//
//  PrimeAdInfoView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct PrimeAdInfoView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                hero

                spotlightCard

                topRankingCard

                premiumNoteCard

                Spacer(minLength: 16)
            }
            .padding()
        }
        .navigationTitle(L("الإعلان المميز", "Prime Ad"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
    }

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.95),
                            Color.pink.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("🔥 PRIME")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Capsule())

                    Spacer()

                    Image(systemName: "crown.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .bold))
                }

                Text(L("أقوى ظهور داخل التطبيق", "Maximum exposure inside the app"))
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text(L(
                    "هذا الإعلان يظهر في البانر المميز + أعلى نتائج البحث والخريطة حسب الأولوية.",
                    "Shows in the featured banner + top search and map ranking by priority."
                ))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.92))
            }
            .padding(16)
        }
        .frame(height: 170)
        .shadow(color: Color.orange.opacity(0.25), radius: 12, x: 0, y: 6)
    }

    private var spotlightCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("المكان رقم 1: بانر مميز", "Placement #1: Featured banner"))
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6))

                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.orange.opacity(0.20))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "megaphone.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 20, weight: .bold))
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(L("بانر أعلى الشاشة", "Top banner"))
                            .font(.subheadline.weight(.semibold))
                        Text(L(
                            "يظهر للمستخدمين في مناطق الترويج داخل التطبيق (مثل أعلى النتائج/الرئيسية).",
                            "Appears in promotional areas (top of results/home sections)."
                        ))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    }

                    Spacer()
                }
                .padding(12)
            }
        }
        .padding()
        .background(cardBG)
    }

    private var topRankingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("المكان رقم 2: أعلى ترتيب بالخريطة والنتائج", "Placement #2: Top map & results ranking"))
                .font(.headline)

            placementLine(icon: "map.fill", text: L(
                "الخريطة: Pin مميز + أولوية أعلى من الشهري والأسبوعي.",
                "Map: highlighted pin + higher priority than monthly/weekly."
            ))

            placementLine(icon: "list.bullet.rectangle.fill", text: L(
                "النتائج: يظهر ضمن أول النتائج بشكل شبه ثابت.",
                "Results: appears near the very top almost consistently."
            ))

            placementLine(icon: "magnifyingglass.circle.fill", text: L(
                "البحث: الأفضلية القصوى عند بحث المستخدم عن نفس الفئة.",
                "Search: maximum advantage when users search your category."
            ))
        }
        .padding()
        .background(cardBG)
    }

    private var premiumNoteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("ملاحظة مهمة", "Important note"))
                .font(.headline)

            Text(L(
                "Prime مخصص لأفضل ظهور، وقد يتم تحديد عدد Prime لكل منطقة لضمان الجودة وعدم الإزعاج.",
                "Prime is for maximum exposure. We may limit Prime spots per area to keep quality."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)

            Divider().opacity(0.2)

            Text(L("المواصفات:", "Specs:"))
                .font(.subheadline.weight(.semibold))

            Text(L(
                "• صورة + عنوان + وصف قصير (150 حرف).\n• أولوية قصوى.\n• أماكن ظهور متعددة داخل التطبيق.",
                "• Photo + title + short text (150 chars).\n• Maximum priority.\n• Multiple placements inside the app."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBG)
    }

    private func placementLine(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 22)
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
