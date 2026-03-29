import Testing
@testable import Gitivity

@Suite("AuthService Tests")
struct AuthServiceTests {

    @Test("초기 상태 - 토큰 없으면 미인증")
    func initialStateUnauthenticated() async {
        let service = AuthService()
        let isAuth = await service.isAuthenticated
        #expect(isAuth == false)
    }

    @Test("loadToken - 토큰 없으면 nil")
    func loadTokenWhenEmpty() async {
        let service = AuthService()
        let token = await service.loadToken()
        #expect(token == nil)
    }

    @Test("signOut - 인증 상태 false로 변경")
    func signOutSetsUnauthenticated() async throws {
        let service = AuthService()
        try await service.signOut()
        let isAuth = await service.isAuthenticated
        #expect(isAuth == false)
    }
}
