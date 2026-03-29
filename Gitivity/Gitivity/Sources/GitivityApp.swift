import SwiftUI
import FoundationModels

@main
struct GitivityApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if !authViewModel.isAuthenticated {
                    OnboardingPageView()
                } else if SystemLanguageModel.default.availability != .available {
                    AIUnavailableView()
                } else {
                    MainTabView()
                }
            }
            .environment(authViewModel)
        }
    }
}
