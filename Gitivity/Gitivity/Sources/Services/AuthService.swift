import Foundation

@Observable
final class AuthService {
    private(set) var isAuthenticated = false
    private(set) var accessToken: String?

    func signInWithGitHub() async throws {
        // TODO: ASWebAuthenticationSession을 사용한 GitHub OAuth
    }

    func signOut() {
        accessToken = nil
        isAuthenticated = false
    }
}
