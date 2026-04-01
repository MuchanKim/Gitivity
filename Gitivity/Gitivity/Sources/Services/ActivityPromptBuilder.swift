import Foundation

nonisolated struct ActivityPromptBuilder: Sendable {

    func buildRepoSummaryPrompt(
        repoName: String,
        pullRequests: [PullRequest],
        commits: [Commit]
    ) -> String {
        let topCommits = selectTopCommits(commits, count: 2)

        var parts: [String] = []
        parts.append("[레포지토리] \(repoName)")

        if !pullRequests.isEmpty {
            parts.append("")
            parts.append("[Pull Requests]")
            for pr in pullRequests.prefix(5) {
                let status = pr.mergedAt != nil ? "머지됨" : "진행중"
                parts.append("(\(status)) \(pr.title)")
                if !pr.body.isEmpty {
                    let trimmed = String(pr.body.prefix(200))
                    parts.append("  설명: \(trimmed)")
                }
            }
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
        if !topCommits.isEmpty {
            parts.append("""
            위 주요 변경 커밋 \(topCommits.count)개를 기반으로 핵심 변경사항을 요약해주세요.
            출력 형식: 정확히 2줄. 각 줄은 "· "로 시작. 마크다운 금지.
            톤: 보고서 (~되었습니다)
            예시:
            · 에러 핸들링 구조가 도메인별 독립 로딩으로 전환되었습니다.
            · FoundationModels API 안정화 및 구조화된 로깅이 추가되었습니다.
            """)
        } else {
            parts.append("""
            위 활동의 핵심 변경사항을 요약해주세요.
            출력 형식: 정확히 2줄. 각 줄은 "· "로 시작. 마크다운 금지.
            톤: 보고서 (~되었습니다)
            예시:
            · 에러 핸들링 구조가 도메인별 독립 로딩으로 전환되었습니다.
            · FoundationModels API 안정화 및 구조화된 로깅이 추가되었습니다.
            """)
        }

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
        톤: 보고서 (~되었습니다)
        예시:
        · 전체 화면 단일 로딩에서 도메인별 독립 로딩으로 전환되었습니다.
        · Skeleton UI와 인라인 에러 피드백이 도입되었습니다.
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

    // MARK: - Private

    private func selectTopCommits(_ commits: [Commit], count: Int) -> [Commit] {
        Array(commits.sorted { ($0.additions + $0.deletions) > ($1.additions + $1.deletions) }.prefix(count))
    }
}
