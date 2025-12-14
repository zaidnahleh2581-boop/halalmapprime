import SwiftUI

struct RootView: View {

    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        MainTabView()
            .environmentObject(lang)
    }
}
