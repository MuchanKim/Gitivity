import Foundation

@Observable
final class AuthViewModel {
    private let authService = AuthService()

    var isAuthenticated: Bool { authService.isAuthenticated }

    func signIn() async {
        do {
            try await authService.signInWithGitHub()
        } catch {
            // TODO: 에러 처리
        }
    }

    func signOut() {
        authService.signOut()
    }
}
