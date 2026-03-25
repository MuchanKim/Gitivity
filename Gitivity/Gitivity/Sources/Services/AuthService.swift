import AuthenticationServices
import Foundation

actor AuthService {
    private let clientID = "PLACEHOLDER_CLIENT_ID"
    private let proxyBaseURL = "PLACEHOLDER_PROXY_URL"
    private let keychain = KeychainService()

    private(set) var isAuthenticated = false

    func checkExistingToken() async {
        isAuthenticated = await (try? keychain.read(key: "github_token")) != nil
    }

    func startOAuth() async throws {
        let code = try await requestAuthorizationCode()
        let token = try await exchangeCodeForToken(code)
        try await keychain.save(key: "github_token", value: token)
        isAuthenticated = true
    }

    func loadToken() async -> String? {
        await (try? keychain.read(key: "github_token"))
    }

    func signOut() async throws {
        try await keychain.delete(key: "github_token")
        isAuthenticated = false
    }

    // MARK: - Private

    private func requestAuthorizationCode() async throws -> String {
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope=repo&redirect_uri=gitivity://auth")!

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callback: .customScheme("gitivity")
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let url = callbackURL,
                      let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: AuthError.noCode)
                    return
                }
                continuation.resume(returning: code)
            }
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }

    private func exchangeCodeForToken(_ code: String) async throws -> String {
        guard proxyBaseURL != "PLACEHOLDER_PROXY_URL" else {
            throw AuthError.proxyNotConfigured
        }

        var request = URLRequest(url: URL(string: "\(proxyBaseURL)/token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["code": code])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.tokenExchangeFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return tokenResponse.accessToken
    }
}

enum AuthError: LocalizedError {
    case noCode
    case tokenExchangeFailed
    case proxyNotConfigured

    var errorDescription: String? {
        switch self {
        case .noCode: "GitHub에서 인증 코드를 받지 못했습니다."
        case .tokenExchangeFailed: "토큰 교환에 실패했습니다."
        case .proxyNotConfigured: "OAuth 프록시 서버가 설정되지 않았습니다."
        }
    }
}

private nonisolated struct TokenResponse: Decodable {
    let accessToken: String
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
