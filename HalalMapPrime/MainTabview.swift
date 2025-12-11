import SwiftUI

/// الجذر الجديد للتطبيق: 3 تبويبات (خريطة / مجتمع / إسلاميات)
struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        TabView {

            // TAB 1: الخريطة (كما هي الآن)
            MapScreen()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text(L("الخريطة", "Map"))
                }

            // TAB 2: مركز المجتمع (إعلانات + وظائف + فعاليات)
            CommunityHubScreen()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text(L("المجتمع", "Community"))
                }

            // TAB 3: أدوات المسلم (صلاة / قبلة / زكاة)
            FaithToolsScreen()
                .tabItem {
                    Image(systemName: "moon.stars.fill")
                    Text(L("إسلاميات", "Faith"))
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(LanguageManager())
    }
}
