# Gitivity — Project Rules

## Platform
- iOS 26+ / iPadOS 26+ (동시 대응)
- macOS는 v2.0 ~ v3.0에서 검토 예정. 현재는 iOS/iPadOS만 타겟.

## Tech Stack
- Swift 6.2+
- SwiftUI (UIKit 사용 금지 — 명시적 요청 없는 한)
- FoundationModels (Apple on-device AI)
- GitHub GraphQL / REST API
- Cloudflare Workers (OAuth 프록시)

## Design
- Liquid Glass 디자인 시스템 적극 적용 (iOS 26+)
- `NavigationSplitView` 사용하여 iPad에서 자동 2-column 레이아웃

## Skills — 우선 적용
아래 스킬이 관련 작업에 해당하면 **반드시** 먼저 호출할 것:
- `liquid-glass` — UI 작성/수정 시
- `swiftui-pro` — SwiftUI 코드 작성/리뷰 시
- `swift-concurrency-pro` — async/await, 동시성 코드 작성 시
- `swift-testing-pro` — 테스트 코드 작성 시

## MCP
- GitHub 관련 작업(PR, Issue, 코드 검색 등)은 `gh` CLI 대신 **GitHub MCP 도구를 우선 사용**한다.

## App Store 규정 준수

이 앱은 **앱스토어 배포 필수**이므로, 아래 사항을 반드시 지킨다.

### 인증 (Sign in with Apple)
- GitHub OAuth만 사용한다. Gitivity는 GitHub 전용 클라이언트이므로 Sign in with Apple 예외 조건 4번("특정 제3자 서비스의 클라이언트") 해당.
- 단, App Review Notes에 반드시 예외 사유를 영문으로 기재할 것:
  > "This app is a dedicated GitHub client. GitHub authentication is required to access the user's own GitHub data via GitHub API. Sign in with Apple cannot provide GitHub API access."
- **리뷰 거부 대비**: 거부 시 Sign in with Apple → 게스트 모드 + GitHub 별도 연동 구조로 전환할 준비.

### 개인정보 보호
- **Privacy Policy 웹페이지**: 앱 배포 전 반드시 작성·호스팅 (수집 데이터, 용도, 공유 여부, 삭제 방법, 연락처 포함).
- **App Privacy Nutrition Labels**: App Store Connect에 다음을 정확히 선언:
  - User ID (GitHub 사용자명) — App Functionality, Linked
  - Name (GitHub 표시 이름) — App Functionality, Linked
  - Photos (GitHub 아바타) — App Functionality, Linked
  - Other Data (기여도 데이터) — App Functionality, Linked
  - 추적 용도: No / 제3자 공유: No
- **OAuth 토큰**: 반드시 Keychain에 저장. UserDefaults 저장 절대 금지.
- **On-device AI 강조**: FoundationModels는 데이터가 기기를 떠나지 않으므로, Privacy Policy 및 앱 설명에 이 점을 명시.

### 계정 삭제 (Guideline 5.1.1v)
- 로그인 기능이 있으면 앱 내 계정 삭제(데이터 정리)도 제공해야 한다.
- 설정 화면에 다음을 포함:
  1. Keychain에서 OAuth 토큰 삭제
  2. GitHub OAuth 토큰 revoke API 호출
  3. 로컬 캐시 데이터 전부 삭제
  4. 로그아웃 상태로 전환

### AI 생성 콘텐츠
- AI 요약 결과에 "AI가 생성한 요약입니다" 라벨을 표시한다.
- FoundationModels 미지원 기기(A17 Pro 미만)에서는 AI 요약을 graceful하게 비활성화하고, 대체 UI를 보여준다.

### 앱 완성도 (Guideline 2.1)
- 제출 시 모든 기능이 정상 동작해야 한다. placeholder/TODO 화면 금지.
- Cloudflare Workers 프록시 서버가 반드시 가동 중이어야 한다.
- App Review Information에 **테스트용 GitHub 계정**을 제공해야 한다.

### App Tracking Transparency
- 현재 광고/추적 SDK를 사용하지 않으므로 ATT 불필요.
- **향후 분석 SDK(Firebase 등) 도입 시 반드시 ATT 재검토.**

## Conventions
- 서드파티 프레임워크 도입 전 반드시 사용자에게 확인
- 타입별로 별도 Swift 파일 분리 (한 파일에 여러 struct/class/enum 금지)
- Feature 단위 폴더 구조

## Repository Hygiene
- `docs/superpowers/` (설계 spec, 구현 plan)은 **커밋하지 않는다**. 로컬 참고용으로만 사용하고 `.gitignore`에 등록되어 있음.
- main/develop 브랜치에는 **프로덕션 코드와 직접 관련된 파일만** 포함한다. 설계 문서, 작업 계획, 에이전트 설정 파일 등은 git history로 추적 가능하므로 레포에 남기지 않는다.
