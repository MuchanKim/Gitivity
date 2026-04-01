import Foundation

nonisolated struct ActivityPromptBuilder: Sendable {

    func buildRepoSummaryPrompt(
        repoName: String,
        pullRequests: [PullRequest],
        categorizedCommits: [CommitCategory: [String]]
    ) -> String {
        var parts: [String] = []
        parts.append("[레포지토리] \(repoName)")

        if !pullRequests.isEmpty {
            parts.append("")
            parts.append("[Pull Requests]")
            for pr in pullRequests.prefix(5) {
                let status = pr.mergedAt != nil ? "머지됨" : "진행중"
                parts.append("(\(status)) \(pr.title)")
            }
        }

        if !categorizedCommits.isEmpty {
            parts.append("")
            parts.append("[변경 사항]")
            for (category, messages) in categorizedCommits.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
                let topMessages = messages.prefix(3).map {
                    $0.components(separatedBy: "\n").first ?? $0
                }
                parts.append("\(category.rawValue): \(topMessages.joined(separator: ", "))")
            }
        }

        parts.append("")
        parts.append("""
        위 최근 작업을 자연스러운 한국어 문단으로 요약해주세요.
        규칙:
        - 순수 텍스트. 마크다운 금지. 줄바꿈 금지. 한 문단으로 작성.
        - 레포지토리 이름, 소유자 이름을 언급하지 마세요. UI에 이미 표시됩니다.
        - 주관적 평가 금지. "매력적으로", "효율적으로 개선", "안정성을 높이는" 등 의견 표현 금지. 무엇이 변경되었는지(What)만 서술.
        - PR이 있으면 PR 단위로 어떤 작업이 완료/진행되었는지 서술.
        - 커밋은 카테고리별로 묶어서 서술.
        - 핵심 내용을 3~4문장으로 압축. 너무 길게 쓰지 마세요.
        - 톤: 보고서 (~되었습니다, ~이루어졌습니다)
        예시: "에러 핸들링 구조를 도메인별 독립 로딩으로 전환하고 Skeleton UI를 도입하는 작업이 머지되었습니다. FoundationModels API 연동 코드 안정화 및 로깅 인프라가 추가되었습니다."
        """)

        return parts.joined(separator: "\n")
    }

    func buildPRSummaryPrompt(
        title: String,
        body: String,
        commits: [Commit]
    ) -> String {
        let topCommits = selectTopCommits(commits, count: 2)

        var parts: [String] = []
        parts.append("[Pull Request] \(title)")

        if !body.isEmpty {
            let trimmed = String(body.prefix(500))
            parts.append("[설명] \(trimmed)")
        }

        if !topCommits.isEmpty {
            parts.append("")
            parts.append("[주요 변경 커밋]")
            for commit in topCommits {
                let firstLine = commit.message.components(separatedBy: "\n").first ?? commit.message
                parts.append("\(firstLine) (+\(commit.additions) -\(commit.deletions))")
            }
        }

        parts.append("")
        parts.append("""
        이 PR의 핵심 변경사항을 요약해주세요.
        출력 형식: 정확히 2줄. 각 줄은 "· "로 시작. 마크다운 금지.
        관련 변경을 묶어서 한 줄에 2개씩 포함.
        톤: 보고서 (~되었습니다)
        예시:
        · 도메인별 독립 로딩 전환 및 Skeleton UI가 도입되었습니다.
        · AI 요약 파이프라인 개선과 에러 핸들링이 추가되었습니다.
        """)

        return parts.joined(separator: "\n")
    }

    func buildCommitDescriptionPrompt(_ message: String) -> String {
        """
        다음 git commit 메시지를 기반으로, 코드베이스에 어떤 변경이 적용되었는지 설명해주세요.
        출력 형식: 순수 텍스트 1줄. 마크다운 금지.
        톤: 보고서 (~되었습니다, ~적용되었습니다)
        예시: 입력 "fix: resolve null crash on login" → "로그인 시 발생하던 null 참조 크래시 처리가 적용되었습니다."
        예시: 입력 "feat: add dark mode toggle" → "설정 화면에 다크모드 전환 기능이 구현되었습니다."

        Commit: \(message)
        """
    }

    func buildRepoOnepagerPrompt(
        repoName: String,
        description: String?,
        readmeExcerpt: String?,
        languages: [String],
        recentActivity: String
    ) -> String {
        var parts: [String] = []
        parts.append("[레포지토리] \(repoName)")

        if let description, !description.isEmpty {
            parts.append("[설명] \(description)")
        }

        if !languages.isEmpty {
            parts.append("[기술 스택] \(languages.joined(separator: ", "))")
        }

        if let readme = readmeExcerpt, !readme.isEmpty {
            let trimmed = String(readme.prefix(1500))
            parts.append("")
            parts.append("[README 발췌]")
            parts.append(trimmed)
        }

        parts.append("")
        parts.append("[최근 활동] \(recentActivity)")

        parts.append("")
        parts.append("""
        위 정보를 기반으로 이 프로젝트가 무엇인지, 최근 어떤 작업에 집중하고 있는지 설명해주세요.
        출력 형식: 정확히 3줄. 마크다운 금지. 순수 텍스트.
        1줄: 프로젝트가 무엇인지 (한 문장)
        2줄: 주요 기술 스택과 특징
        3줄: 최근 집중하고 있는 작업
        톤: 보고서 (~입니다, ~있습니다)
        """)

        return parts.joined(separator: "\n")
    }

    func buildTranslationPrompt(_ text: String) -> String {
        let truncated = String(text.prefix(3000))
        return """
        다음 영문 텍스트를 한국어로 번역해주세요.
        규칙:
        - 기술 용어(OAuth, API, token 등)는 원문 유지
        - 마크다운 서식이 있으면 그대로 유지
        - 자연스러운 한국어로 번역 (직역 금지)
        - 번역문만 출력. 설명이나 주석 금지.

        원문:
        \(truncated)
        """
    }

    // MARK: - Private

    private func selectTopCommits(_ commits: [Commit], count: Int) -> [Commit] {
        Array(commits.sorted { ($0.additions + $0.deletions) > ($1.additions + $1.deletions) }.prefix(count))
    }
}
