import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab(StringLiterals.Tab.feed, systemImage: "list.clipboard") {
                ActivityFeedView()
            }

            Tab(StringLiterals.Tab.profile, systemImage: "person") {
                ProfileView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
