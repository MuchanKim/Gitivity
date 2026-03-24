# Gitivity — 개발 환경 셋업 가이드

> 다른 컴퓨터에서 이 프로젝트를 작업할 때 참고하는 문서.

---

## 요구 사항

| 항목 | 버전 |
|------|------|
| Xcode | 26.0+ |
| iOS Deployment Target | 26.0 |
| Swift | 6.0+ |
| macOS | 26.0+ (Tahoe) |
| Git | 2.x |
| Claude Code CLI | 최신 |

---

## 초기 셋업

### 1. 레포지토리 클론

```bash
git clone https://github.com/MuchanKim/Gitivity.git
cd Gitivity
```

### 2. Xcode 프로젝트 열기

```bash
open Gitivity/Gitivity.xcodeproj
```

- Signing & Capabilities에서 **Team을 본인 Apple Developer 계정으로 변경**
- Bundle Identifier는 `com.moo.Gitivity` (필요 시 변경)

### 3. Claude Code 환경 준비

`.claude/` 폴더는 `.gitignore`에 의해 추적되지 않으므로, 각 머신에서 개별로 설정됩니다.

```bash
# Claude Code 로그인 (아직 안 했다면)
claude login

# 프로젝트 디렉토리에서 Claude Code 실행
claude
```

프로젝트 규칙은 `CLAUDE.md`에, 디자인 스펙/플랜은 `docs/superpowers/`에 있으며 git으로 동기화됩니다.

### 4. 빌드 & 실행

- Xcode에서 시뮬레이터 또는 실기기 선택 후 `Cmd + R`
- FoundationModels는 **실기기에서만** 동작 (시뮬레이터에서는 빌드만 가능)

---

## 프로젝트 구조

```
Gitivity/
├── CLAUDE.md                  # AI 에이전트 프로젝트 규칙 (git 추적)
├── SETUP.md                   # 이 문서
├── .gitignore
├── docs/superpowers/          # 디자인 스펙 & 구현 플랜 (git 추적)
│   ├── specs/
│   └── plans/
└── Gitivity/
    └── Gitivity/
        ├── Sources/           # 앱 소스 코드
        │   ├── Models/
        │   ├── Services/
        │   ├── ViewModels/
        │   ├── Views/
        │   └── Utilities/
        ├── Resources/         # Assets, 리소스
        └── Tests/             # 유닛/UI 테스트
```

---

## Git 추적 정책

| 파일/폴더 | 추적 여부 | 이유 |
|-----------|----------|------|
| `CLAUDE.md` | O | 프로젝트 규칙, 여러 머신에서 동기화 필요 |
| `docs/superpowers/` | O | 스펙/플랜, 여러 머신에서 동기화 필요 |
| `.claude/` | X | 로컬 세션 데이터, 머신별 독립 |
| `.cursor/`, `.copilot/` 등 | X | 에디터별 로컬 설정 |
| `*.xcuserdata/` | X | Xcode 개인 설정 |
| `*.env`, `secrets/` | X | 시크릿 파일 |

---

## 멀티 머신 작업 시 주의사항

1. **작업 전 항상 `git pull`** — 다른 머신에서의 변경사항 반영
2. **브랜치 분리 권장** — 같은 브랜치에서 두 머신이 동시 작업하면 충돌 가능
3. **Xcode Signing** — 각 머신에서 Team 설정이 다를 수 있음, `.xcuserdata/`는 추적 안 함
4. **Claude Code 메모리** — `.claude/` 폴더는 로컬이므로 머신 간 Claude 대화 히스토리는 공유 안 됨. 프로젝트 컨텍스트는 `CLAUDE.md`와 `docs/superpowers/`로 공유
