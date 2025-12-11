import SwiftUI

struct AdsHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        NavigationStack {
            ScrollView {

                VStack(alignment: .leading, spacing: 20) {

                    Text(lang.isArabic ? "الإعلانات" : "Advertisements")
                        .font(.largeTitle.bold())
                        .padding(.top, 10)

                    Text(lang.isArabic ?
                         "اختر نوع الإعلان الذي تريد إضافته أو معرفة تفاصيله." :
                         "Choose the type of advertisement you want to add or learn more about.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    // إعلان مجاني
                    adButton(
                        titleAR: "إعلان مجاني (مرة واحدة فقط)",
                        titleEN: "Free Ad (One time)",
                        color: .green
                    )

                    // إعلان مدفوع
                    adButton(
                        titleAR: "إعلان مدفوع (شهري / أسبوعي)",
                        titleEN: "Paid Ad (Monthly / Weekly)",
                        color: .blue
                    )

                    // Prime Ads
                    adButton(
                        titleAR: "Prime Ads (أفضل ظهور)",
                        titleEN: "Prime Ads (Best visibility)",
                        color: .red
                    )
                }
                .padding()
            }
            .navigationTitle(lang.isArabic ? "الإعلانات" : "Ads")
        }
    }

    // MARK: - Button Component
    func adButton(titleAR: String, titleEN: String, color: Color) -> some View {
        Button {

        } label: {
            Text(lang.isArabic ? titleAR : titleEN)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(14)
        }
    }
}

struct AdsHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        AdsHomeScreen()
            .environmentObject(LanguageManager())
    }
}
