import SwiftUI

struct AdsHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @State private var showComingSoon = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    // Header
                    Text(lang.isArabic ? "الإعلانات المدفوعة" : "Paid Ads")
                        .font(.largeTitle.bold())
                        .padding(.top, 8)

                    Text(lang.isArabic
                         ? "هذا القسم مخصص للإعلانات المدفوعة لزيادة ظهور نشاطك على الخريطة والبنرات داخل التطبيق."
                         : "This section is for paid promotions to boost your visibility on the map and banners inside the app.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    // Orange premium banner (similar spirit to your community orange card)
                    premiumBanner

                    // Actions
                    VStack(spacing: 12) {

                        actionButton(
                            titleAR: "ابدأ إعلان مدفوع (أسبوعي / شهري)",
                            titleEN: "Start a Paid Ad (Weekly / Monthly)",
                            systemImage: "creditcard.fill",
                            tint: .orange
                        ) {
                            showComingSoon = true
                        }

                        actionButton(
                            titleAR: "Prime Ads (أفضل ظهور)",
                            titleEN: "Prime Ads (Best visibility)",
                            systemImage: "sparkles",
                            tint: .orange
                        ) {
                            showComingSoon = true
                        }

                        actionButton(
                            titleAR: "إعلاناتي",
                            titleEN: "My Ads",
                            systemImage: "doc.text.magnifyingglass",
                            tint: .orange
                        ) {
                            showComingSoon = true
                        }
                    }
                    .padding(.top, 4)

                    Text(lang.isArabic
                         ? "ملاحظة: سيتم ربط الدفع (In-App Purchases) لاحقاً بطريقة رسمية ومتوافقة مع Apple."
                         : "Note: Payments (In-App Purchases) will be connected later in an official Apple-compliant way.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)

                    Spacer(minLength: 24)
                }
                .padding()
            }
            .navigationTitle(lang.isArabic ? "إعلانات مدفوعة" : "Paid Ads")
            .navigationBarTitleDisplayMode(.inline)
            .alert(lang.isArabic ? "قريباً" : "Coming Soon", isPresented: $showComingSoon) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(lang.isArabic
                     ? "هذه الميزة قيد التجهيز. سنفعّلها قريباً."
                     : "This feature is being prepared and will be enabled soon.")
            }
        }
    }

    private var premiumBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.98),
                            Color.orange.opacity(0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.18))
                    Image(systemName: "megaphone.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.isArabic ? "روّج لعملك الحلال" : "Promote your halal business")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(lang.isArabic
                         ? "ظهور أعلى على الخريطة + بنرات داخل التطبيق."
                         : "Higher visibility on the map + banners inside the app.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)

                    Text(lang.isArabic ? "Prime • كوبونات • عروض" : "Prime • Coupons • Offers")
                        .font(.caption2.bold())
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.20))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.top, 2)
                }

                Spacer()
            }
            .padding(14)
        }
        .frame(height: 110)
        .shadow(color: Color.orange.opacity(0.25), radius: 8, x: 0, y: 4)
    }

    private func actionButton(
        titleAR: String,
        titleEN: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                Text(lang.isArabic ? titleAR : titleEN)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.92))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}
