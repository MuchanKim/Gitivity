import SwiftUI

@main
struct GitivityApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if !authViewModel.isAuthenticated {
                    OnboardingPageView()
                } else {
                    MainTabView()
                }
            }
            .environment(authViewModel)
        }
    }
}
