import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("피드", systemImage: "list.clipboard") {
                ActivityFeedView()
            }

            Tab("프로필", systemImage: "person") {
                ProfileView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
