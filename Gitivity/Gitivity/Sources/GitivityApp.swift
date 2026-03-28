import SwiftUI

@main
struct GitivityApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environment(authViewModel)
            } else {
                OnboardingView()
                    .environment(authViewModel)
            }
        }
    }
}
