import Foundation

@Observable
@MainActor
final class AuthViewModel {
    private(set) var isAuthenticated = false
    private(set) var isLoading = false
    var error: String?

    private let authService = AuthService()

    init() {
        authService.checkExistingToken()
        isAuthenticated = authService.isAuthenticated
    }

    func signIn() async {
        isLoading = true
        error = nil
        do {
            try await authService.startOAuth()
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            // signOut 실패는 무시
        }
        isAuthenticated = false
    }
}
