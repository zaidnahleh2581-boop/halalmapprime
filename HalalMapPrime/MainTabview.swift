import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager
    @State private var selectedTab = 0

    private var homeTitle: String { lang.isArabic ? "الرئيسية" : "Home" }
    private var jobsTitle: String { lang.isArabic ? "وظائف" : "Jobs" }
    private var adsTitle: String { lang.isArabic ? "إعلانات" : "Ads" }
    private var moreTitle: String { lang.isArabic ? "المزيد" : "More" }

    var body: some View {
        TabView(selection: $selectedTab) {

            // 1) Home
            HomeOverviewScreen()
                .tag(0)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(homeTitle)
                }

            // 2) Jobs (مؤقت/لو عندك شاشة وظائف حقيقية حطها هنا)
            JobAdsBoardView()
                .tag(1)
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text(jobsTitle)
                }

            // 3) Paid Ads
            AdsHomeScreen()
                .tag(2)
                .tabItem {
                    Image(systemName: "megaphone.fill")
                    Text(adsTitle)
                }

            // 4) More (الخصوصية والشروط وكل شيء)
            MoreScreen()
                .tag(3)
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text(moreTitle)
                }
        }
        .tint(.orange)
    }
}
