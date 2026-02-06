//
//  AdminGateView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Updated by Zaid Nahleh on 2026-02-05.
//

import SwiftUI

struct AdminGateView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            List {

                Section(L("الإدارة", "Admin")) {

                    NavigationLink(L("📢 لوحة الإعلانات", "📢 Ads Dashboard")) {
                        AdminAdsDashboardView()
                    }

                    NavigationLink(L("💼 الوظائف", "💼 Jobs")) {
                        AdminJobsDashboardPlaceholderView()
                            .navigationTitle(L("الوظائف", "Jobs"))
                    }

                    NavigationLink(L("📅 الفعاليات", "📅 Events")) {
                        AdminEventsDashboardPlaceholderView()
                            .navigationTitle(L("الفعاليات", "Events"))
                    }

                    NavigationLink(L("📍 الأماكن", "📍 Places")) {
                        AdminPlacesListView()
                            .navigationTitle(L("الأماكن", "Places"))
                    }
                }

                Section {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text(L("إغلاق الإدارة", "Close Admin"))
                    }
                }
            }
            .navigationTitle(L("لوحة الإدارة", "Admin Panel"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Temporary placeholders (until we plug real dashboards)
private struct AdminJobsDashboardPlaceholderView: View {
    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        List {
            Text(L("جاهز. الخطوة التالية: نربطها بـ jobAds ونضيف Hide/Delete/Approve.", "Ready. Next: connect to jobAds and add Hide/Delete/Approve."))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AdminEventsDashboardPlaceholderView: View {
    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        List {
            Text(L("جاهز. الخطوة التالية: نربطها بـ eventAds/cityEventAds ونضيف Hide/Delete.", "Ready. Next: connect to eventAds/cityEventAds and add Hide/Delete."))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
