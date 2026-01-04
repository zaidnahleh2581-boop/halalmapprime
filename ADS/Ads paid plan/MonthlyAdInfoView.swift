//
//  MonthlyAdInfoView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct MonthlyAdInfoView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                header

                placementGrid

                benefitsCard

                noteCard

                Spacer(minLength: 16)
            }
            .padding()
        }
        .navigationTitle(L("الإعلان الشهري", "Monthly Ad"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
    }

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.22),
                            Color.teal.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.green)

                    Spacer()

                    Text(L("30 يوم", "30 Days"))
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.22))
                        .clipShape(Capsule())
                }

                Text(L("انتشار ثابت لمدة شهر", "Stable exposure for a full month"))
                    .font(.title2.bold())

                Text(L(
                    "أفضل من الأسبوعي في الثبات والظهور، ويعطيك فرصة تجمع زيارات وتقييمات بشكل مستمر.",
                    "Stronger consistency than weekly. Great for steady visits and reviews."
                ))
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(14)
        }
        .frame(height: 160)
        .shadow(color: Color.green.opacity(0.18), radius: 10, x: 0, y: 6)
    }

    private var placementGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("أماكن الظهور", "Ad placements"))
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                smallCard(
                    icon: "map",
                    title: L("الخريطة", "Map"),
                    detail: L("Pin مميز + أولوية أعلى من الأسبوعي/المجاني.", "Highlighted pin + higher priority than weekly/free.")
                )

                smallCard(
                    icon: "list.number",
                    title: L("النتائج", "Results"),
                    detail: L("يظهر ضمن أعلى النتائج لفترة أطول.", "Stays near the top longer.")
                )

                smallCard(
                    icon: "rectangle.stack.fill",
                    title: L("بطاقات داخل التطبيق", "In-app cards"),
                    detail: L("يظهر في مساحات الترويج داخل الصفحات.", "Appears in promotional sections.")
                )

                smallCard(
                    icon: "magnifyingglass.circle",
                    title: L("البحث", "Search"),
                    detail: L("أفضلية عند بحث المستخدم عن نفس الفئة.", "Advantage when users search same category.")
                )
            }
        }
        .padding()
        .background(cardBG)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("ليش الشهري أفضل؟", "Why monthly is better"))
                .font(.headline)

            Text(L(
                "لأنه يعطيك مدة كافية حتى المستخدمين يلاحظوا المحل أكثر من مرة ويصير عندك تكرار بالزيارات.",
                "It gives enough time for users to notice you repeatedly and build returning visits."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)

            Divider().opacity(0.2)

            HStack(spacing: 12) {
                statChip(title: L("مدة", "Duration"), value: L("30 يوم", "30 days"), icon: "clock")
                statChip(title: L("قوة الظهور", "Visibility"), value: "★★★", icon: "sparkles")
            }

            bullet(L("صورة + وصف قصير (150 حرف).", "Photo + short text (150 chars)."))
            bullet(L("ترتيب أعلى من الأسبوعي.", "Ranks above weekly."))
            bullet(L("أفضل للتسويق المستمر.", "Best for ongoing marketing."))
        }
        .padding()
        .background(cardBG)
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("ملاحظة", "Note"))
                .font(.headline)
            Text(L(
                "إذا في أكثر من إعلان شهري بنفس المنطقة، يتم تدويرهم حسب نظام الأولوية.",
                "If multiple monthly ads exist in the same area, they rotate by priority."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBG)
    }

    private func smallCard(icon: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.system(size: 18, weight: .semibold))
            Text(title).font(.subheadline.weight(.semibold))
            Text(detail).font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }

    private func statChip(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption2).foregroundColor(.secondary)
                Text(value).font(.footnote.weight(.bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .foregroundColor(.green)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•").font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
