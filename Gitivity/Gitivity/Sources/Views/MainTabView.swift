import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("피드", systemImage: "list.bullet") {
                FeedView()
            }

            Tab("요약", systemImage: "chart.bar") {
                SummaryView()
            }

            Tab("설정", systemImage: "gearshape") {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
