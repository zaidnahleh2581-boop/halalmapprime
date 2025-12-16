//
//  CommunityHubScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import SwiftUI

/// مركز المجتمع في Halal Map Prime:
/// - إعلانات مجانية (وظائف + فعاليات + لوحة عامة)
/// - توثيق موقعك على الخريطة (Verified Your Location)
/// - ميزات قادمة
struct CommunityHubScreen: View {

    @EnvironmentObject var lang: LanguageManager

    // شيتات
    @State private var showJobsBoard: Bool = false
    @State private var showEventsBoard: Bool = false
    @State private var showNoticeBoard: Bool = false
    @State private var showAddPlace: Bool = false

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    headerSection
                        .padding(.horizontal)

                    freeAdsSection
                        .padding(.horizontal)

                    // ✅ بدل AddMasjid/AddRestaurant... نخليها توثيق
                    verifyLocationSection
                        .padding(.horizontal)

                    comingSoonSection
                        .padding(.horizontal)

                    Spacer(minLength: 16)
                }
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(L("مركز المجتمع", "Community hub"))
            .navigationBarTitleDisplayMode(.inline)

            .sheet(isPresented: $showJobsBoard) {
                JobAdsBoardView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showEventsBoard) {
                EventAdsBoardView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showNoticeBoard) {
                NoticeBoardView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showAddPlace) {
                // نفس الشاشة الحالية، لكن الفكرة “Verify”
                AddStoreScreen()
                    .environmentObject(lang)
            }
        }
    }
}

// MARK: - Sections

private extension CommunityHubScreen {

    var headerSection: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.02, green: 0.35, blue: 0.28),
                                Color(red: 0.00, green: 0.60, blue: 0.52)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "person.3.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(L("مجتمع حلال ماب برايم", "Halal Map Prime community"))
                    .font(.headline)

                Text(
                    L(
                        "كل ما يخص المجتمع المسلم حولك من وظائف، فعاليات، ومساحة إعلانات عامة في مكان واحد.",
                        "Everything happening in the Muslim community around you: jobs, events, and a community notice board."
                    )
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    var freeAdsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("إعلانات المجتمع المجانية", "Free community ads"))
                .font(.subheadline.bold())

            Text(
                L(
                    "نساعد من يبحث عن عمل أو يعلن عن فعالية أو ينشر إعلاناً عاماً داخل المجتمع المسلم.",
                    "We help people looking for jobs, posting events or sharing general notices inside the Muslim community."
                )
            )
            .font(.caption)
            .foregroundColor(.secondary)

            VStack(spacing: 10) {

                FreeAdCard(
                    title: L("إعلانات الوظائف", "Job ads"),
                    subtitle: L("أبحث عن عمل أو أبحث عن موظف", "Looking for a job or hiring"),
                    icon: "briefcase.fill",
                    accent: .green
                ) { showJobsBoard = true }

                FreeAdCard(
                    title: L("إعلانات الفعاليات", "Events ads"),
                    subtitle: L("إفطارات، دروس، لقاءات، نشاطات للمجتمع", "Iftars, lectures, meetups and community activities"),
                    icon: "calendar.badge.plus",
                    accent: .blue
                ) { showEventsBoard = true }

                FreeAdCard(
                    title: L("لوحة الإعلانات العامة", "Community notice board"),
                    subtitle: L("إعلانات عامة، تنبيهات، أشياء مفقودة، وغير ذلك", "General announcements, alerts, lost & found and more"),
                    icon: "text.bubble.fill",
                    accent: .teal
                ) { showNoticeBoard = true }
            }
        }
    }

    /// ✅ القسم الجديد: Verify Your Location
    var verifyLocationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("وثّق موقعك على الخريطة", "Verify your location on the map"))
                .font(.subheadline.bold())

            Text(
                L(
                    "إذا عندك مطعم أو محل حلال: قدّم طلب توثيق لموقعك ليظهر بشكل رسمي داخل Halal Map Prime.",
                    "If you own a halal restaurant or store: submit a verification request so your place appears officially on Halal Map Prime."
                )
            )
            .font(.caption)
            .foregroundColor(.secondary)

            Button {
                showAddPlace = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("وثّق مطعمك / محلك (Halal Verified)", "Verify your restaurant / store (Halal Verified)"))
                            .font(.subheadline.bold())

                        Text(
                            L(
                                "ارسل معلومات موقعك وسيتم مراجعته وإضافته بشكل موثّق.",
                                "Submit your place details and it will be reviewed and added as verified."
                            )
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
    }

    var comingSoonSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("ميزات قادمة للمجتمع", "Coming soon for the community"))
                .font(.subheadline.bold())

            VStack(spacing: 10) {
                comingSoonRow(
                    icon: "cart.badge.plus",
                    title: L("سوق مجتمعي للمنتجات الحلال", "Community halal marketplace"),
                    message: L(
                        "مساحة لبيع وشراء المنتجات الحلال بين أفراد المجتمع.",
                        "A space to buy and sell halal products between community members."
                    )
                )

                comingSoonRow(
                    icon: "heart.text.square",
                    title: L("مساحة خاصة للجمعيات الخيرية والزكاة", "Space for charities & zakat"),
                    message: L(
                        "معلومات عن حملات خيرية وطرق موثوقة للتبرّع والزكاة.",
                        "Information about charity campaigns and trusted ways to donate and give zakat."
                    )
                )
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
    }

    func comingSoonRow(icon: String, title: String, message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                Text(message)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

// MARK: - Free Ad Card

private struct FreeAdCard: View {

    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accent.opacity(0.14))
                    Image(systemName: icon)
                        .font(.headline)
                        .foregroundColor(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
