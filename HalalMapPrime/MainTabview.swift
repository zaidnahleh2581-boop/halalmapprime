import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager
    @State private var selectedTab: Int = 1

    private var tintColor: Color {
        switch selectedTab {
        case 0: return .blue        // Add Location
        case 2: return .teal        // Faith Tools
        case 4: return .orange      // Paid Ads
        default: return .green      // Map / Community
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // 0️⃣ Add Location (Blue)
            AddStoreScreen()
                .tag(0)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text(lang.isArabic ? "أضف عنوانك" : "Add Location")
                }

            // 1️⃣ Map (Center)
            MapScreen()
                .tag(1)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text(lang.isArabic ? "الخريطة" : "Map")
                }

            // 2️⃣ Faith Tools (NEW)
            FaithToolsScreen()
                .tag(2)
                .tabItem {
                    Image(systemName: "moon.stars.fill")
                    Text(lang.isArabic ? "أدوات الإيمان" : "Faith")
                }

            // 3️⃣ Community
            CommunityHubScreen()
                .tag(3)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text(lang.isArabic ? "الكميونتي" : "Community")
                }

            // 4️⃣ Paid Ads (Orange) — ONLY Paid Ads entry point
            AdsHomeScreen()
                .tag(4)
                .tabItem {
                    Image(systemName: "megaphone.fill")
                    Text(lang.isArabic ? "إعلانات مدفوعة" : "Paid Ads")
                }
        }
        .tint(tintColor)
    }
}
