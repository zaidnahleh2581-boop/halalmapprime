import SwiftUI

/// شاشة مركز الإعلانات داخل Halal Map Prime
/// تصميم بسيط جدًا – كل شيء على شكل كروت واضحة:
/// - إعلان مجاني لمحل أو خدمة
/// - إعلان وظائف (أبحث عن عمل / أبحث عن موظّف)
/// - إعلان فعاليات المجتمع
/// - خطط الإعلانات المدفوعة
/// - شاشة "إعلاناتي"
struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // شيتات فرعية
    @State private var showFreeAdForm: Bool = false
    @State private var showJobAds: Bool = false
    @State private var showEventAdComposer: Bool = false
    @State private var showPaidAdPlans: Bool = false
    @State private var showPrimeAdPlans: Bool = false
    @State private var showMyAds: Bool = false

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    headerSection
                    infoSection

                    // الكروت الرئيسية
                    VStack(spacing: 14) {

                        // 1) إعلان مجاني لمحل / خدمة
                        AdsHomeCard(
                            title: L("إعلان مجاني لمحلّك", "Free listing for your business"),
                            subtitle: L(
                                "أضف محل حلال أو خدمة بسيطة ليظهر في نتائج البحث داخل التطبيق.",
                                "Add a halal shop or simple service so it appears in search results."
                            ),
                            systemIcon: "mappin.and.ellipse",
                            tint: .green
                        ) {
                            showFreeAdForm = true
                        }

                        // 2) إعلانات الوظائف
                        AdsHomeCard(
                            title: L("إعلانات وظائف (أبحث عن عمل / موظّف)", "Job ads (looking for job / staff)"),
                            subtitle: L(
                                "نموذج جاهز: اكتب اسمك والمدينة ونوع المكان، والنظام يجهّز نص الإعلان تلقائيًا.",
                                "Structured template: fill your name, city and place type, we generate the ad text for you."
                            ),
                            systemIcon: "briefcase.fill",
                            tint: .blue
                        ) {
                            showJobAds = true
                        }

                        // 3) إعلان فعالية للمجتمع
                        AdsHomeCard(
                            title: L("إعلان فعالية للمجتمع", "Community event ad"),
                            subtitle: L(
                                "أعلن عن بازار، إفطار جماعي، محاضرة، أو أي نشاط للمسلمين في مدينتك.",
                                "Post a bazaar, community iftar, lecture or any Muslim community event."
                            ),
                            systemIcon: "calendar.badge.plus",
                            tint: .orange
                        ) {
                            showEventAdComposer = true
                        }

                        // 4) خطط إعلانات مدفوعة
                        AdsHomeCard(
                            title: L("خطط إعلانات مدفوعة", "Paid ad plans"),
                            subtitle: L(
                                "باقات يومية / أسبوعية / شهرية لظهور أقوى في الخريطة والبنرات.",
                                "Daily / weekly / monthly plans for stronger visibility in map and banners."
                            ),
                            systemIcon: "creditcard.fill",
                            tint: .purple
                        ) {
                            showPaidAdPlans = true
                        }

                        // 5) Prime Ads – أعلى الخريطة
                        AdsHomeCard(
                            title: L("Prime Ads (أعلى الخريطة)", "Prime Ads (top of the map)"),
                            subtitle: L(
                                "أفضل ظهور ممكن – بانر مميّز أعلى الصفحة الرئيسية والخريطة.",
                                "Maximum exposure with a featured banner on top of the main map screen."
                            ),
                            systemIcon: "star.circle.fill",
                            tint: .pink
                        ) {
                            showPrimeAdPlans = true
                        }

                        // 6) إعلاناتي
                        AdsHomeCard(
                            title: L("إعلاناتي", "My ads"),
                            subtitle: L(
                                "راجع الإعلانات التي أنشأتها من قبل وقم بإدارتها بسهولة.",
                                "View and manage the ads you have created before."
                            ),
                            systemIcon: "doc.text.magnifyingglass",
                            tint: .teal
                        ) {
                            showMyAds = true
                        }
                    }

                    footerSection
                }
                .padding()
            }
            .navigationTitle(L("مركز الإعلانات", "Ads center"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
            // MARK: - الشاشات الفرعية (Sheets)

            .sheet(isPresented: $showFreeAdForm) {
                FreeAdFormView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showJobAds) {
                JobAdsBoardView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showEventAdComposer) {
                EventAdComposerView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPaidAdPlans) {
                SelectAdPlanView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPrimeAdPlans) {
                // حالياً نستخدم نفس شاشة SelectAdPlanView للـ Prime
                SelectAdPlanView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showMyAds) {
                MyAdsView()
                    .environmentObject(lang)
            }
        }
    }

    // MARK: - أقسام أعلى وأسفل

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("الإعلانات في Halal Map Prime", "Ads in Halal Map Prime"))
                .font(.title2.weight(.semibold))

            Text(
                L(
                    "كل أنواع الإعلانات في مكان واحد: للمحلات، الوظائف، والفعاليات، بخطوات بسيطة واضحة.",
                    "All ad types in one place: for businesses, jobs and events, with very simple clear steps."
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    private var infoSection: some View {
        Text(
            L(
                "لا تحتاج لكتابة نصوص طويلة أو معقدة. أغلب الجمل جاهزة، فقط اختر نوع الإعلان وأدخل المعلومات الأساسية.",
                "You do not need to write long or complex texts. Most sentences are pre-written; just choose the ad type and fill basic fields."
            )
        )
        .font(.footnote)
        .foregroundColor(.secondary)
    }

    private var footerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L("سياسة الإعلانات", "Ad policy"))
                .font(.footnote.weight(.semibold))

            Text(
                L(
                    "كل الإعلانات يجب أن تكون حلال، قانونية داخل الولايات المتحدة، ومطابقة لقواعد Apple App Store وقوانين Halal Map Prime.",
                    "All ads must be halal, legal in the USA, and compliant with Apple App Store rules and Halal Map Prime guidelines."
                )
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
}

// MARK: - مكوّن كرت الإعلان في الصفحة الرئيسية

private struct AdsHomeCard: View {

    let title: String
    let subtitle: String
    let systemIcon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {

                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(tint.opacity(0.18))
                    Image(systemName: systemIcon)
                        .font(.title3)
                        .foregroundColor(tint)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct AdsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        AdsHomeView()
            .environmentObject(LanguageManager())
    }
}
