import AuthenticationServices
import Foundation
import UIKit

@MainActor
final class AuthService {
    private let clientID: String
    private let proxyBaseURL: String
    private let keychain = KeychainService()

    private var authSession: ASWebAuthenticationSession?
    private let contextProvider = AuthPresentationContext()

    init() {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GitHubClientID") as? String,
              !clientID.isEmpty,
              let proxyURL = Bundle.main.object(forInfoDictionaryKey: "OAuthProxyURL") as? String,
              !proxyURL.isEmpty else {
            fatalError("Secrets.xcconfig이 설정되지 않았습니다. Secrets.template.xcconfig를 참고하세요.")
        }
        self.clientID = clientID
        self.proxyBaseURL = proxyURL
    }

    private(set) var isAuthenticated = false

    func checkExistingToken() {
        isAuthenticated = (try? keychain.read(key: "github_token")) != nil
    }

    func startOAuth() async throws {
        let code = try await requestAuthorizationCode()
        let token = try await exchangeCodeForToken(code)
        try keychain.save(key: "github_token", value: token)
        isAuthenticated = true
    }

    func loadToken() -> String? {
        try? keychain.read(key: "github_token")
    }

    func signOut() throws {
        try keychain.delete(key: "github_token")
        isAuthenticated = false
    }

    // MARK: - Private

    private func requestAuthorizationCode() async throws -> String {
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope=repo&redirect_uri=gitivity://auth")!

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callback: .customScheme("gitivity")
            ) { [weak self] callbackURL, error in
                self?.authSession = nil

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
            session.presentationContextProvider = self.contextProvider
            self.authSession = session
            session.start()
        }
    }

    private func exchangeCodeForToken(_ code: String) async throws -> String {
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

    var errorDescription: String? {
        switch self {
        case .noCode: "GitHub에서 인증 코드를 받지 못했습니다."
        case .tokenExchangeFailed: "토큰 교환에 실패했습니다."
        }
    }
}

private struct TokenResponse: Decodable {
    let accessToken: String
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

@MainActor
private final class AuthPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first(where: \.isKeyWindow) else {
            return ASPresentationAnchor()
        }
        return window
    }
}
