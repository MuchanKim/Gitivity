# OAuth (앱 쪽) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** GitHub OAuth 로그인의 앱 쪽 흐름을 구현한다. 프록시 서버 연동은 별도 플랜으로 분리하고, 이 플랜에서는 프록시 URL만 주입하면 완성되는 상태까지 만든다.

**Architecture:** ASWebAuthenticationSession으로 GitHub OAuth 인증 → 임시 코드 수신 → 프록시 서버에 토큰 교환 요청 → Keychain에 토큰 저장. AuthService(actor)가 인증 로직을 캡슐화하고, AuthViewModel(@Observable)이 UI 상태를 관리한다.

**Tech Stack:** Swift 6.2, SwiftUI, AuthenticationServices, Security (Keychain)

**Spec:** `docs/superpowers/specs/2026-03-24-gitivity-design.md`

---

## File Structure

```
Gitivity/Gitivity/Sources/
├── Services/
│   ├── KeychainService.swift       # (수정) static enum → struct, Security 프레임워크 사용
│   └── AuthService.swift           # (수정) actor, ASWebAuthenticationSession + 토큰 교환
├── ViewModels/
│   └── AuthViewModel.swift         # (수정) @Observable, 로그인/로그아웃/에러 상태
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift    # (수정) 로그인 버튼 + 에러 표시 + 로딩 상태
│   └── Settings/
│       └── SettingsView.swift      # (수정) 로그아웃 버튼 추가
└── GitivityApp.swift               # (수정) authViewModel을 Environment로 전달

Gitivity/Gitivity/Tests/
└── GitivityTests/
    ├── KeychainServiceTests.swift  # (리네이밍) Keychain CRUD 테스트
    └── AuthServiceTests.swift      # (생성) AuthService 상태 테스트
```

---

## Task 1: KeychainService 구현

**Files:**
- Modify: `Gitivity/Gitivity/Sources/Services/KeychainService.swift`
- Rename: `Gitivity/Gitivity/Tests/GitivityTests/GitivityTests.swift` → `KeychainServiceTests.swift`

- [ ] **Step 1: 테스트 파일 리네이밍**

```bash
mv Gitivity/Gitivity/Tests/GitivityTests/GitivityTests.swift Gitivity/Gitivity/Tests/GitivityTests/KeychainServiceTests.swift
```

- [ ] **Step 2: 테스트 작성**

`Gitivity/Gitivity/Tests/GitivityTests/KeychainServiceTests.swift`:
```swift
import Testing
@testable import Gitivity

@Suite("KeychainService Tests")
struct KeychainServiceTests {
    let keychain = KeychainService()

    @Test("토큰 저장 후 읽기")
    func saveAndRead() throws {
        try keychain.save(key: "test_token", value: "abc123")
        let result = try keychain.read(key: "test_token")
        #expect(result == "abc123")
        try keychain.delete(key: "test_token")
    }

    @Test("존재하지 않는 키 읽기")
    func readNonExistent() {
        let result = try? keychain.read(key: "nonexistent_key_xyz")
        #expect(result == nil)
    }

    @Test("토큰 삭제")
    func deleteToken() throws {
        try keychain.save(key: "delete_test", value: "value")
        try keychain.delete(key: "delete_test")
        let result = try? keychain.read(key: "delete_test")
        #expect(result == nil)
    }

    @Test("토큰 덮어쓰기")
    func overwrite() throws {
        try keychain.save(key: "overwrite_test", value: "old")
        try keychain.save(key: "overwrite_test", value: "new")
        let result = try keychain.read(key: "overwrite_test")
        #expect(result == "new")
        try keychain.delete(key: "overwrite_test")
    }
}
```

- [ ] **Step 3: 테스트 실행 — 실패 확인**

```bash
xcodebuild test -project Gitivity/Gitivity.xcodeproj -scheme Gitivity -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:GitivityTests 2>&1 | tail -20
```
Expected: FAIL — `KeychainService`에 `read` 메서드 없음

- [ ] **Step 4: KeychainService 구현**

`Gitivity/Gitivity/Sources/Services/KeychainService.swift`:
```swift
import Foundation
import Security

struct KeychainService: Sendable {
    private let serviceName = "com.moo.Gitivity"

    func save(key: String, value: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func read(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.readFailed(status)
        }
        return String(data: data, encoding: .utf8)
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
}
```

- [ ] **Step 5: 테스트 실행 — 통과 확인**

```bash
xcodebuild test -project Gitivity/Gitivity.xcodeproj -scheme Gitivity -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:GitivityTests 2>&1 | tail -20
```
Expected: 4개 테스트 PASS

- [ ] **Step 6: 커밋**

```bash
git add Gitivity/Gitivity/Sources/Services/KeychainService.swift Gitivity/Gitivity/Tests/
git commit -m "feat: implement keychainservice with secure token storage

What?
- Implement KeychainService struct with save/read/delete using Security framework.
- Add 4 unit tests for Keychain CRUD operations.
- Rename GitivityTests.swift to KeychainServiceTests.swift.

- Security 프레임워크를 사용한 KeychainService 구현 (저장/읽기/삭제).
- Keychain CRUD 유닛 테스트 4개 추가.
- GitivityTests.swift를 KeychainServiceTests.swift로 리네이밍.

---
Committed by Claude Code (claude-opus-4-6)"
```

---

## Task 2: AuthService 구현

**Files:**
- Modify: `Gitivity/Gitivity/Sources/Services/AuthService.swift`
- Create: `Gitivity/Gitivity/Tests/GitivityTests/AuthServiceTests.swift`

- [ ] **Step 1: AuthService 테스트 작성**

`Gitivity/Gitivity/Tests/GitivityTests/AuthServiceTests.swift`:
```swift
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
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
xcodebuild test -project Gitivity/Gitivity.xcodeproj -scheme Gitivity -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:GitivityTests/AuthServiceTests 2>&1 | tail -20
```
Expected: FAIL — 현재 AuthService가 `@Observable class`이므로 `actor`로 변경 필요

- [ ] **Step 3: AuthService 구현**

`Gitivity/Gitivity/Sources/Services/AuthService.swift`:
```swift
import AuthenticationServices
import Foundation

actor AuthService {
    private let clientID = "PLACEHOLDER_CLIENT_ID"
    private let proxyBaseURL = "PLACEHOLDER_PROXY_URL"
    private let keychain = KeychainService()

    private(set) var isAuthenticated = false

    init() {
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

private struct TokenResponse: Decodable {
    let accessToken: String
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
xcodebuild test -project Gitivity/Gitivity.xcodeproj -scheme Gitivity -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:GitivityTests/AuthServiceTests 2>&1 | tail -20
```
Expected: 3개 테스트 PASS

- [ ] **Step 5: 커밋**

```bash
git add Gitivity/Gitivity/Sources/Services/AuthService.swift Gitivity/Gitivity/Tests/GitivityTests/AuthServiceTests.swift
git commit -m "feat: implement authservice with github oauth flow

What?
- Implement AuthService as actor with ASWebAuthenticationSession OAuth flow.
- Add token exchange via proxy server (placeholder URL for now).
- Add AuthError with localized Korean error messages.
- Add 3 unit tests for AuthService state management.

- ASWebAuthenticationSession 기반 GitHub OAuth 흐름을 actor로 구현.
- 프록시 서버를 통한 토큰 교환 구현 (현재 placeholder URL).
- 한국어 에러 메시지를 포함한 AuthError 추가.
- AuthService 상태 관리 유닛 테스트 3개 추가.

---
Committed by Claude Code (claude-opus-4-6)"
```

---

## Task 3: URL Scheme 등록 + AuthViewModel 업데이트

**Files:**
- Modify: `Gitivity/Gitivity/Sources/ViewModels/AuthViewModel.swift`
- Note: Xcode에서 URL Scheme 등록 필요 (Target → Info → URL Types)

- [ ] **Step 1: URL Scheme 등록**

Xcode에서 다음을 설정:
1. Gitivity 타겟 선택 → Info 탭
2. URL Types 섹션에서 "+" 클릭
3. URL Schemes: `gitivity`
4. Identifier: `com.moo.Gitivity`
5. Role: Editor

이 설정이 없으면 `ASWebAuthenticationSession`의 콜백 (`gitivity://auth?code=xxx`)이 앱으로 돌아오지 않음.

- [ ] **Step 2: AuthViewModel 구현**

`Gitivity/Gitivity/Sources/ViewModels/AuthViewModel.swift`:
```swift
import Foundation

@Observable
@MainActor
final class AuthViewModel {
    private(set) var isAuthenticated = false
    private(set) var isLoading = false
    var error: String?

    private let authService = AuthService()

    init() {
        Task { await checkExistingToken() }
    }

    func checkExistingToken() async {
        isAuthenticated = await authService.loadToken() != nil
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

    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            // signOut 실패는 무시
        }
        isAuthenticated = false
    }
}
```

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild build -project Gitivity/Gitivity.xcodeproj -scheme Gitivity -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 4: 커밋**

```bash
git add Gitivity/Gitivity/Sources/ViewModels/AuthViewModel.swift
git commit -m "feat: update authviewmodel with login/logout state management

What?
- Update AuthViewModel to use actor-based AuthService.
- Add isLoading and error state for UI feedback.
- Add signIn/signOut/checkExistingToken async methods.

- actor 기반 AuthService를 사용하도록 AuthViewModel 업데이트.
- UI 피드백을 위한 isLoading, error 상태 추가.
- signIn/signOut/checkExistingToken async 메서드 추가.

---
Committed by Claude Code (claude-opus-4-6)"
```

---

## Task 4: OnboardingView + GitivityApp + SettingsView 업데이트

**Files:**
- Modify: `Gitivity/Gitivity/Sources/Views/Onboarding/OnboardingView.swift`
- Modify: `Gitivity/Gitivity/Sources/Views/Settings/SettingsView.swift`
- Modify: `Gitivity/Gitivity/Sources/GitivityApp.swift`

- [ ] **Step 1: OnboardingView 구현**

`Gitivity/Gitivity/Sources/Views/Onboarding/OnboardingView.swift`:
```swift
import SwiftUI

struct OnboardingView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Gitivity")
                .font(.largeTitle.bold())

            Text("GitHub 활동을 AI가 정리해주는\n나만의 개발 회고 도구")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                Task { await authViewModel.signIn() }
            } label: {
                HStack(spacing: 8) {
                    if authViewModel.isLoading {
                        ProgressView()
                    }
                    Text("GitHub로 로그인")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(authViewModel.isLoading)

            if let error = authViewModel.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()
                .frame(height: 40)
        }
        .padding(24)
    }
}

#Preview {
    OnboardingView()
        .environment(AuthViewModel())
}
```

- [ ] **Step 2: SettingsView에 로그아웃 버튼 추가**

`Gitivity/Gitivity/Sources/Views/Settings/SettingsView.swift`:
```swift
import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("잔디 테마") {
                    Text("컬러 선택")
                }

                Section("AI Provider") {
                    Text("Foundation Models (On-Device)")
                }

                Section("계정") {
                    Button("로그아웃", role: .destructive) {
                        Task { await authViewModel.signOut() }
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthViewModel())
}
```

- [ ] **Step 3: GitivityApp에 Environment 전달**

`Gitivity/Gitivity/Sources/GitivityApp.swift`:
```swift
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
```

- [ ] **Step 4: 빌드 및 UI 확인**

```bash
xcodebuild build -project Gitivity/Gitivity.xcodeproj -scheme Gitivity -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

시뮬레이터에서 확인:
- 앱 실행 → OnboardingView 표시
- "GitHub로 로그인" 버튼 보임
- 버튼 탭 → OAuth 웹뷰 표시 (프록시 미설정이므로 코드 수신 후 "프록시 서버가 설정되지 않았습니다" 에러 표시)

- [ ] **Step 5: 커밋**

```bash
git add Gitivity/Gitivity/Sources/Views/ Gitivity/Gitivity/Sources/GitivityApp.swift
git commit -m "feat: complete oauth ui with onboarding, login, and logout flow

What?
- Update OnboardingView with login button, loading state, and error display.
- Add logout button to SettingsView.
- Pass AuthViewModel as Environment from GitivityApp to all child views.

- OnboardingView에 로그인 버튼, 로딩 상태, 에러 표시 추가.
- SettingsView에 로그아웃 버튼 추가.
- GitivityApp에서 모든 하위 뷰로 AuthViewModel을 Environment로 전달.

---
Committed by Claude Code (claude-opus-4-6)"
```

---

## 완료 후 상태

- [x] KeychainService — Keychain CRUD 완성 + 테스트 4개
- [x] AuthService — GitHub OAuth 흐름 (actor) + 테스트 3개
- [x] URL Scheme — `gitivity://` 콜백 스킴 등록
- [x] AuthViewModel — 인증 상태 관리 (@Observable + @MainActor)
- [x] OnboardingView — 로그인 버튼 + 로딩 + 에러 표시
- [x] SettingsView — 로그아웃 버튼
- [x] GitivityApp — 인증 상태 분기 + Environment 전달
- [ ] **미완료**: OAuth 프록시 서버 배포 + `clientID` / `proxyBaseURL` 실제 값 설정 → 별도 플랜

---

*Written by Claude Code (claude-opus-4-6)*
