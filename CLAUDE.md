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

## Conventions
- 서드파티 프레임워크 도입 전 반드시 사용자에게 확인
- 타입별로 별도 Swift 파일 분리 (한 파일에 여러 struct/class/enum 금지)
- Feature 단위 폴더 구조
