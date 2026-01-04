//
//  WeeklyAdInfoView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct WeeklyAdInfoView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                header

                placementsCard

                whatYouGetCard

                rulesCard

                Spacer(minLength: 16)
            }
            .padding()
        }
        .navigationTitle(L("الإعلان الأسبوعي", "Weekly Ad"))
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
                .fill(Color.blue.opacity(0.18))

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.blue.opacity(0.25), lineWidth: 1)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.blue)
                    Spacer()
                    Text(L("7 أيام", "7 Days"))
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.22))
                        .clipShape(Capsule())
                }

                Text(L("ظهور قوي لمدة أسبوع", "Strong visibility for one week"))
                    .font(.title2.bold())

                Text(L(
                    "مناسب للعروض الأسبوعية والافتتاحات. إعلانك يظهر أعلى من الإعلانات العادية داخل النتائج.",
                    "Perfect for weekly promos and openings. Your ad ranks above normal results."
                ))
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(14)
        }
        .frame(height: 150)
    }

    private var placementsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("أين سيظهر إعلانك بالضبط؟", "Where will your ad show?"))
                .font(.headline)

            placementRow(
                icon: "map.fill",
                title: L("على الخريطة", "On the map"),
                detail: L(
                    "علامة (Pin) مميزة + يظهر ضمن أماكن أقرب وأعلى من الإدراجات العادية.",
                    "A highlighted pin + ranks above normal listings nearby."
                )
            )

            placementRow(
                icon: "list.bullet.rectangle",
                title: L("في قائمة النتائج", "In results list"),
                detail: L(
                    "يظهر في أعلى القائمة قبل النتائج المجانية (حسب الترتيب داخل التطبيق).",
                    "Appears higher in the list than free entries (based on in-app ranking)."
                )
            )

            placementRow(
                icon: "magnifyingglass",
                title: L("عند البحث", "When searching"),
                detail: L(
                    "عندما يبحث المستخدم عن نفس الفئة/المنطقة، إعلانك يكون ضمن أول النتائج.",
                    "When users search same category/area, your ad can appear among the top."
                )
            )
        }
        .padding()
        .background(cardBG)
    }

    private var whatYouGetCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("ماذا ستحصل؟", "What you get"))
                .font(.headline)

            bullet(L("مدة: 7 أيام كاملة.", "Duration: full 7 days."))
            bullet(L("أولوية أعلى من الإدراجات المجانية.", "Higher priority than free listings."))
            bullet(L("مناسب لحملات قصيرة وسريعة.", "Ideal for short campaigns."))
            bullet(L("إمكانية إضافة صورة + وصف قصير (150 حرف).", "Add a photo + short text (150 chars)."))
        }
        .padding()
        .background(cardBG)
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("ملاحظات مهمة", "Important notes"))
                .font(.headline)

            Text(L(
                "الظهور يعتمد على فئة الإعلان والمنطقة. أي محتوى مخالف سيتم رفضه.",
                "Visibility depends on category and area. Any violating content will be rejected."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBG)
    }

    private func placementRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .frame(width: 26)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
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
