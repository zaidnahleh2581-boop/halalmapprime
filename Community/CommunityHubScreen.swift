//
//  CommunityHubScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import UIKit

struct CommunityHubScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @State private var showComposer: Bool = false
    @State private var showMyEvents: Bool = false
    @State private var selectedCategory: CoreEventCategory = .all

    // ✅ Admin Secret Gate
    @State private var showAdminPrompt: Bool = false
    @State private var adminCode: String = ""
    @State private var adminError: String? = nil
    @State private var showAdminPanel: Bool = false

    // ✅ غيّر هذا الرمز لأي شيء بدك
    private let adminSecretCode = "ZAID-ADMIN-2026"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Top Bar (Contact + Privacy)
                HStack {
                    NavigationLink {
                        ContactUsView()
                            .environmentObject(lang)
                    } label: {
                        Text(L("اتصل بنا", "Contact Us"))
                            .font(.footnote.weight(.semibold))
                    }

                    Spacer()

                    NavigationLink {
                        PrivacyPolicyView()
                            .environmentObject(lang)
                    } label: {
                        Text(L("الخصوصية", "Privacy"))
                            .font(.footnote.weight(.semibold))
                    }
                    // ✅ Secret Admin trigger (Long press 2s on Privacy)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 2.0).onEnded { _ in
                            adminCode = ""
                            adminError = nil
                            showAdminPrompt = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    )
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // ✅ Core 10 Tabs (fixed)
                coreCategoryTabs
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                // Main content (events list filtered)
                EventAdsBoardView(selectedCategory: selectedCategory)
                    .environmentObject(lang)
            }
            .navigationTitle(L("فعاليات المجتمع", "Community Events"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // ✅ My Events + Add
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        showMyEvents = true
                    } label: {
                        Label(L("فعالياتي", "My Events"), systemImage: "person.crop.circle")
                    }

                    Button {
                        showComposer = true
                    } label: {
                        Label(L("أضف", "Add"), systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showComposer) {
                EventAdComposerView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showMyEvents) {
                MyEventsView()
                    .environmentObject(lang)
            }

            // ✅ Admin Code Prompt
            .sheet(isPresented: $showAdminPrompt) {
                NavigationStack {
                    VStack(spacing: 16) {
                        Text(L("دخول الإدارة", "Admin Login"))
                            .font(.title3.weight(.semibold))
                            .padding(.top, 10)

                        Text(L("هذه الصفحة مخفية. أدخل الرمز للمتابعة.", "This page is hidden. Enter the code to continue."))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        SecureField(L("رمز الإدارة", "Admin code"), text: $adminCode)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)

                        if let adminError {
                            Text(adminError)
                                .foregroundStyle(.red)
                                .font(.footnote.weight(.semibold))
                                .padding(.top, 2)
                        }

                        Button {
                            if adminCode.trimmingCharacters(in: .whitespacesAndNewlines) == adminSecretCode {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showAdminPrompt = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    showAdminPanel = true
                                }
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                adminError = L("رمز خاطئ. حاول مرة أخرى.", "Wrong code. Try again.")
                            }
                        } label: {
                            Text(L("دخول", "Enter"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.top, 20)
                    .navigationTitle("Admin")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(L("إغلاق", "Close")) { showAdminPrompt = false }
                        }
                    }
                }
            }

            // ✅ Admin Panel
            .sheet(isPresented: $showAdminPanel) {
                AdminGateView()
                    .environmentObject(lang)
            }
        }
    }

    // MARK: - Tabs UI

    private var coreCategoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CoreEventCategory.allCases) { cat in
                    let title = lang.isArabic ? cat.title.ar : cat.title.en

                    Button {
                        selectedCategory = cat
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Text(title)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(selectedCategory == cat ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == cat
                                          ? Color.blue
                                          : Color(.secondarySystemGroupedBackground))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}
