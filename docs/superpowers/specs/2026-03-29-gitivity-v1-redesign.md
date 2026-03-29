# Gitivity v1.0 — 디자인 스펙

## 1. 앱 개요

### 핵심 가치
에이전트 시대에 개발자가 자신의 창작물을 이해하는 능력이 중요하다. Gitivity는 GitHub에 저장된 데이터(커밋, PR, 이슈)를 on-device AI가 사람이 이해할 수 있는 형태로 번역해주는 앱이다.

### 타겟 사용자
- AI 에이전트를 활용해 개발하는 iOS/소프트웨어 엔지니어
- 자기 작업을 정리하고 회고하고 싶은 개발자

### 플랫폼
- iOS 26+ / iPadOS 26+
- 최소 기기: iPhone 15 Pro (A17 Pro) — FoundationModels 필수
- iPad M1+ 지원 (NavigationSplitView 2-column adaptive)

### 앱스토어 배포
- 경쟁 앱 없음 (2026-03-29 기준)
- GitHub OAuth만 사용 (Sign in with Apple 예외 조건 4번 해당)

## 2. 기술 스택

### AI
- **기본**: Apple FoundationModels (on-device, 무료)
- **향후 확장**: AIProvider 프로토콜 기반으로 Claude API, OpenAI 등 플러그인 가능
- **컨텍스트 제약**: 4096 토큰 (input + output 합산)
- **한국어**: 공식 지원. 시스템 프롬프트는 영어, 출력은 한국어 요청

### AI가 하는 일
| 기능 | 입력 | 방식 |
|------|------|------|
| 레포 요약 | 커밋 메시지 + PR 제목 | FoundationModels 텍스트 생성 |
| PR 요약 | PR 제목/본문 + 커밋 메시지 | FoundationModels 텍스트 생성 |
| 커밋 번역 | 커밋 메시지 | FoundationModels 텍스트 생성 |
| 활동 분류 | 커밋 메시지 | @Generable 구조화 출력 (feat/fix/refactor/style/chore/docs/test) |

### 활동 분류 전략
- conventional commits prefix (`feat:`, `fix:` 등) → 정규식 파싱 (AI 불필요)
- prefix 없는 커밋 → FoundationModels @Generable로 분류
- 하이브리드 처리로 AI 호출 최소화

### API
- GitHub GraphQL API (viewer, contributions, PRs, issues, commits)
- Cloudflare Workers OAuth 프록시 (구현 완료)

## 3. 앱 구조

### 네비게이션
```
TabView (Liquid Glass, 2탭)
├── 피드 탭
│   ├── 홈 (레포별 타임라인)
│   └── 레포 상세 (push) — PR/커밋 타임라인
└── 프로필 탭
    ├── 프로필 (통계 + 잔디)
    └── 설정 (push via gear)
```

### 화면 목록
1. 온보딩 (3장 스와이프)
2. 홈 — 피드 탭
3. 레포 상세
4. 프로필 탭
5. 설정
6. AI 미지원 기기 안내

## 4. 화면별 디자인 스펙

### 4.1 온보딩

**구조**: 3장 스와이프 + 매 페이지 우측 상단 "건너뛰기"

**1장**
- 아이콘: ✦ (크게)
- 타이틀: "내가 만든 것을 이해하는 방법"
- 설명: "AI가 커밋과 PR을 사람의 말로 요약해줍니다"
- 하단: 페이지 인디케이터 (●○○)

**2장**
- 아이콘: 📊
- 타이틀: "레포별 타임라인"
- 설명: "최근 작업한 레포를 활동 분류와 함께 확인"
- 하단: 페이지 인디케이터 (○●○)

**3장**
- 아이콘: 🔒
- 타이틀: "온디바이스 AI"
- 설명: "데이터가 기기를 떠나지 않습니다"
- CTA: "GitHub로 시작하기" 버튼 (흰색, 풀 너비)
- 하단: "계속하면 개인정보 처리방침에 동의하는 것으로 간주됩니다."
- 페이지 인디케이터 (○○●)

### 4.2 홈 — 피드 탭

**헤더**
- Large Title: "활동"
- 로고/아바타 없음

**피드 구조**: 타임라인 형태
- 좌측: 도트 + 수직 라인
- 도트: 레포별 고유 색상 (indigo, purple, cyan 등)
- 정렬: 마지막 활동 순

**레포 그룹 카드**
- 헤더: 도트 + 레포명 + 시간 (우측)
- 카드 내부:
  - AI 요약 (✦ AI 요약 라벨 + 요약 텍스트)
  - 활동 비율 바 (컬러 세그먼트: feat 초록, fix 주황, style 보라 등)
  - 범례 (도트 + 분류명)
  - 통계 (PR 수, 커밋 수)
- 카드 탭 → 레포 상세로 push

**하단**: Liquid Glass 탭 바 (피드 active, 프로필)

### 4.3 레포 상세

**네비게이션 바**
- 좌측: "‹ 활동" 백버튼
- 우측: ↗ 공유/외부 링크

**레포 헤더** (가운데 정렬)
- 레포명 (22pt bold)
- owner/repo 메타

**AI 요약 카드** (좌측 정렬)
- ✦ AI 요약 라벨
- 레포 전체 활동 요약 텍스트
- "AI가 생성한 요약입니다" 디스클레이머
- 활동 비율 바 + 범례

**PR 카드** (시간순, 최신 먼저)
- 헤더: PULL REQUEST 라벨 + MERGED 배지 + 시간 (우측)
- PR 제목
- ✦ AI 요약 (PR 단위)
- 내포 커밋 목록:
  - 분류 도트 (색상) + AI 번역된 커밋 설명 + additions/deletions (우측)
- 하단 통계: +additions, -deletions, 커밋 수

**독립 커밋 카드** (PR에 속하지 않는 커밋)
- COMMIT 라벨 + 시간
- 커밋 제목
- ✦ AI 번역

**상단 통계 박스 없음** — 레포 전체 누적 통계는 의미 약하므로 제거
**날짜 필터 없음** — MVP에서 불필요, 최신순 정렬로 충분

### 4.4 프로필 탭

**헤더**
- Large Title: "프로필"
- 우측 상단: gear 아이콘 (탭 → 설정 push)

**프로필 히어로** (가운데 정렬)
- GitHub 아바타 (80pt, 원형, fetchViewer의 avatarUrl)
- 이름
- @핸들

**활동 통계** (3박스 가로 배치)
- 커밋 수 / PR 수 / 레포 수

**잔디 컨트리뷰션 그래프**
- "기여 활동" 라벨 + "최근 30일" 우측
- GitHub 스타일 초록 셀 그리드
- fetchContributions API 사용

**활동 분류 바**
- "활동 분류" 라벨
- 컬러 세그먼트 바 (feat/fix/style/chore)
- 범례 (도트 + 분류명 + 퍼센트)

### 4.5 설정

**진입**: 프로필 탭 → gear 아이콘 → NavigationLink push

**네비게이션 바**
- 좌측: "‹ 프로필" 백버튼
- 타이틀: "설정" (가운데)

**그룹별 메뉴** (iOS grouped list 스타일)

**AI 그룹**
- AI 모델 선택 (현재값 표시: "Foundation", 향후 Claude/OpenAI 추가)

**일반 그룹**
- 테마 (현재값 표시: "다크")
- 개인정보 처리방침 (외부 링크)
- 앱 정보 (버전 표시)

**계정 그룹**
- 로그아웃
- 계정 삭제 (빨간색 강조, 탭 시 확인 다이얼로그)

### 4.6 AI 미지원 기기 안내

**표시 조건**: `SystemLanguageModel.default.availability`가 `.available`이 아닌 경우

**구조** (가운데 정렬)
- 아이콘: ✦ (72pt, 보라 배경 박스)
- 타이틀: "Apple Intelligence 필요"
- 설명: Gitivity는 온디바이스 AI를 사용한다는 안내
- CTA: "설정에서 활성화하기" 버튼
- 보조 텍스트: "iPhone 15 Pro 이상 기기에서 사용할 수 있습니다"

## 5. 디자인 시스템

### 컬러
- **배경**: #0f1729 (다크 네이비)
- **카드 배경**: #1a2332
- **AI 카드 배경**: #111d2e
- **보더**: #1e293b
- **Primary**: #6366f1 (Indigo)
- **AI 라벨**: #22d3ee (Cyan)
- **텍스트**: #e2e8f0 (밝은), #94a3b8 (보조), #64748b (흐린), #475569 (메타)
- **위험**: #f87171 (Red)
- **additions**: #4ade80 (Green)
- **deletions**: #f87171 (Red)

### 활동 분류 컬러
- feat: #4ade80 (Green)
- fix: #f59e0b (Amber)
- style/refactor: #a78bfa (Purple)
- chore/docs: #64748b (Gray)

### 타이포그래피
- Large Title: SF Pro Display, 22-24pt, 800 weight
- 카드 제목: 12-13pt, 600-700 weight
- 본문: 10-11pt, 400 weight
- 메타/라벨: 8-9pt, 600-700 weight
- AI 라벨: 7-8pt, 700 weight, letter-spacing 0.5px, uppercase

### 컴포넌트
- **카드**: border-radius 10-14px, 1px solid #1e293b
- **탭 바**: Liquid Glass, border-radius 26px, blur 배경
- **버튼 (CTA)**: border-radius 12px, #6366f1 배경
- **GitHub 로그인**: 흰색 배경, 검정 텍스트, border-radius 14px
- **도트**: 6-8px, border-radius 50%
- **활동 바**: height 4px, border-radius 2px, gap 2px

## 6. 데이터 흐름

```
GitHub GraphQL API
├── fetchViewer() → 프로필 (아바타, 이름)
├── fetchContributions() → 프로필 잔디 그래프
├── fetchPullRequests() → 피드 + 레포 상세
├── fetchIssues() → 피드
└── fetchCommits() → 피드 + 레포 상세

FoundationModels (on-device)
├── 레포 요약 생성
├── PR 요약 생성
├── 커밋 메시지 번역
└── 활동 분류 (@Generable)
```

### 요약 생성 전략
- 한 세션 = 한 요약 요청 (컨텍스트 누적 방지)
- 레포 요약: 해당 레포의 커밋 메시지 + PR 제목을 모아서 1회 요청
- PR 요약: PR 제목 + 본문 + 소속 커밋 메시지를 모아서 1회 요청
- 커밋 번역: 개별 커밋 메시지 1회 요청 (짧으므로 빠름)
- 활동 분류: conventional commits prefix는 정규식, 나머지는 AI

## 7. 앱스토어 규정 준수

- **계정 삭제** (5.1.1v): 설정 → 계정 삭제 (Keychain 토큰 삭제 + OAuth revoke + 캐시 삭제)
- **AI 라벨**: 모든 AI 생성 요약에 "AI가 생성한 요약입니다" 표시
- **프라이버시**: on-device AI, 데이터가 기기를 떠나지 않음
- **AI 미지원 fallback**: A17 Pro 미만 기기 안내 화면 제공
- **Privacy Policy**: 앱 배포 전 웹페이지 작성 필요

## 8. v1.0 범위 외 (향후)

- v1.1: Wrapped (연간 회고 카드 슬라이드), 소셜 공유
- v2.0: 위젯 (잔디), Cloud AI 옵트인 (Claude/OpenAI)
- 코드 diff 분석 (on-device AI 한계로 제외)
- Impact Score / Deep Reasoning (소형 모델 한계로 제외)
