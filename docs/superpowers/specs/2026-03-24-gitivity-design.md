# Gitivity — Design Spec

> 에이전트 시대의 개발 회고 도구. GitHub 활동을 AI가 정리해주는 나만의 PM.

## Overview

Gitivity는 GitHub 활동 데이터를 수집하고, Apple Foundation 모델(on-device AI)을 활용하여 개발 활동을 자연어로 요약해주는 iOS 앱이다. 에이전트 기반 개발이 보편화되면서 개발자가 자신의 작업 내용을 놓치기 쉬운 문제를 해결한다.

---

## Version Roadmap

### v1 (MVP) — 개발 회고 도구

핵심 가치: "이번 주에 내가 뭘 했는지" AI가 정리해준다.

**인증**
- GitHub OAuth (ASWebAuthenticationSession)
- OAuth token exchange용 경량 서버 (Cloudflare Workers)
- `repo` scope (private 레포 접근)

**데이터**
- GitHub GraphQL API (메인) + REST API (보조)
- 수집 대상: 커밋 메시지, PR 제목/본문/변경 파일 목록, 이슈, 컨트리뷰션 캘린더
- 피드 그룹핑: PR 단위, PR 없는 커밋은 push 단위

**AI**
- AIProvider Protocol (교체 가능한 인터페이스)
- MVP: Apple Foundation 모델 (on-device, 무료)
- 설정에서 Claude API 키 입력 시 전환 가능

**화면 구성**

1. 온보딩
   - GitHub OAuth 로그인 버튼
   - 로그인 성공 → 메인 화면

2. 탭 1: 피드
   - 내 GitHub 활동을 최신순 타임라인으로 표시
   - PR/push 단위로 그룹핑하여 피드 도배 방지
   - 항목 탭 → 상세 화면
     - AI 요약: Foundation 모델이 생성한 활동 설명
     - 변경 사항: 파일 목록, additions/deletions
     - 로우 데이터: 커밋 메시지, 타임라인

3. 탭 2: 요약
   - 상단: 잔디밭 (GitHub 컨트리뷰션 그래프, 컬러 커스텀 가능)
   - 세그먼트: 일간 / 주간 / 월간
   - AI가 생성한 기간별 원페이저 요약
   - 기간 네비게이션 (← 이전 / 다음 →)
   - 요약 내용: 커밋 수, PR/이슈 현황, 활발한 레포, 자연어 회고

4. 설정
   - 잔디 컬러 테마 선택
   - AI Provider 선택 (Foundation / Claude API 키 입력)
   - GitHub 계정 관리 (로그아웃)

**플랫폼**
- iPhone + iPad (iOS 26+ / iPadOS 26+)
- FoundationModels 프레임워크 최소 요구: iOS 26+
- 지원 기기: iPhone 15 Pro 이상 (A17 Pro+), iPad M1 이상

**기술 스택**
- Swift 6.2, SwiftUI
- FoundationModels (Apple on-device AI, iOS 26+)
- Liquid Glass 디자인 시스템
- GitHub GraphQL / REST API
- Cloudflare Workers (OAuth 프록시)

---

### v1.5 — 위젯 & 잔디 강화

핵심 가치: 앱을 열지 않아도 홈화면에서 잔디와 활동을 확인한다.

- WidgetKit 위젯
  - Small: 오늘 커밋 수 + 스트릭 일수
  - Medium: 최근 1주 잔디밭
  - Large: 최근 3개월 잔디밭
- 잔디 컬러 앱 설정과 위젯 동기화

---

### v2 — 활동 게이미피케이션 + macOS 검토

핵심 가치: 잔디 키우기가 재밌어진다.

- 스트릭 연속일수에 따라 잔디 색상 자동 변화
- 월간 활동량 기준 배경/테마 언락
- 목표 설정 ("하루 3커밋", "주 5일 활동")
- 달성률 시각화 및 알림
- macOS 26 지원 검토 시작 (v2.0 ~ v3.0 사이에서 결정)

---

### v3 — 학습 선생님 + macOS 대응

핵심 가치: 내가 뭘 배웠는지 알려준다.

- 레포 단위 활동 분석 및 원페이저 요약
- PR 변경 코드에 대한 AI 설명 (코드베이스 기반)
- 사용한 API, 문법에 대한 문제 자동 생성
- 문제 풀이 및 학습 기록

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                  Gitivity                    │
├─────────────────────────────────────────────┤
│                                             │
│  ┌───────────┐    ┌──────────────────────┐  │
│  │ GitHub    │───▶│ DataService          │  │
│  │ OAuth     │    │ - 커밋, PR, 이슈 수집  │  │
│  └───────────┘    └──────────┬───────────┘  │
│                              │              │
│                              ▼              │
│                   ┌──────────────────────┐  │
│                   │ PromptBuilder        │  │
│                   │ - 데이터 → 프롬프트    │  │
│                   └──────────┬───────────┘  │
│                              │              │
│                              ▼              │
│                   ┌──────────────────────┐  │
│                   │ AIProvider (Protocol) │  │
│                   │ ├─ FoundationProvider │  │
│                   │ └─ ClaudeProvider     │  │
│                   └──────────┬───────────┘  │
│                              │              │
│                    ┌─────────┴─────────┐    │
│                    ▼                   ▼    │
│            ┌─────────────┐   ┌───────────┐ │
│            │ 피드 (탭 1)  │   │ 요약 (탭 2)│ │
│            └─────────────┘   └───────────┘ │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  OAuth Token Exchange (Cloudflare Workers)  │
└─────────────────────────────────────────────┘
```

### Core Modules

- **GitHubService**: OAuth 인증 + GitHub GraphQL/REST API 호출
- **DataService**: 커밋, PR, 이슈 데이터 수집 및 가공, 피드 그룹핑 (PR/push 단위)
- **PromptBuilder**: 수집된 데이터를 AI 프롬프트로 변환 (일간/주간/월간별 템플릿)
- **AIProvider (Protocol)**: Foundation / Claude 등 교체 가능한 AI 인터페이스
- **FeedViewModel**: 피드 탭 데이터 관리 및 페이지네이션
- **SummaryViewModel**: 요약 탭 기간별 데이터 관리 및 잔디밭 렌더링

---

## Competitive Landscape

| 앱 | 핵심 기능 | Gitivity 차별점 |
|---|---|---|
| GitHub 공식 앱 | 잔디밭 위젯 | AI 요약 없음, 회고 기능 없음 |
| Contribution Graphs for GitHub | 잔디밭 + 컬러 테마 | 활동 내용 분석 없음 |
| Git Streak Tracker | 스트릭 추적 | 커밋 수만 보여줌, 내용 요약 없음 |
| Gardener for GitHub | 잔디 동기부여 | AI 없음, 게이미피케이션만 |

**Gitivity의 핵심 차별점**: On-device AI(Foundation 모델)를 활용한 개발 활동 자연어 요약. 기존 앱들이 "숫자"만 보여주는 반면, Gitivity는 "의미"를 전달한다.

---

## Implementation Notes

- **피드 그룹핑**: "PR 없는 커밋은 push 단위"에서 GitHub GraphQL API는 push 이벤트를 직접 제공하지 않으므로, 같은 브랜치 + 시간 근접성 기준으로 그룹핑한다.
- **API 키 보안**: Claude API 키(BYOK)는 iOS Keychain에 저장한다.
- **API rate limit**: 앱 포그라운드 진입 시 fetch + 최소 간격 제한 방식으로 설계한다. 구현 시 구체화.

## Open Questions

- Foundation 모델의 컨텍스트 윈도우 크기에 따라 한 번에 요약 가능한 데이터량이 제한될 수 있음 → 프롬프트 최적화 또는 청킹 전략 필요
- 오프라인 시 캐싱된 데이터로 이전 요약 표시 여부

---

*Written by Claude Code (claude-opus-4-6)*
