import Foundation

nonisolated struct ActivityPromptBuilder: Sendable {
    func buildRepoSummaryPrompt(
        repoName: String,
        pullRequests: [PullRequest],
        commits: [Commit]
    ) -> String {
        var parts: [String] = []
        parts.append("Repository: \(repoName)")

        if !pullRequests.isEmpty {
            parts.append("\nRecent Pull Requests (\(pullRequests.count) total):")
            for pr in pullRequests.prefix(10) {
                parts.append("- \(pr.title)")
            }
            if pullRequests.count > 10 {
                parts.append("- ... and \(pullRequests.count - 10) more")
            }
        }

        if !commits.isEmpty {
            parts.append("\nRecent Commits (\(commits.count) total):")
            for commit in commits.prefix(20) {
                parts.append("- \(commit.message.components(separatedBy: "\n").first ?? commit.message)")
            }
            if commits.count > 20 {
                parts.append("- ... and \(commits.count - 20) more")
            }
        }

        parts.append("")
        parts.append("""
        위 GitHub 활동을 한국어로 요약해주세요.
        규칙:
        - 문장 형태로 작성 (불릿 포인트 사용 금지)
        - 주요 작업 내용을 빠짐없이 포함
        - PR이 있으면 PR 단위로, 없으면 커밋 단위로 설명
        - 3~5문장으로 작성
        - 마크다운 서식(**, *, #, - 등) 사용 금지, 순수 텍스트만
        """)

        return parts.joined(separator: "\n")
    }

    func buildPRSummaryPrompt(
        title: String,
        body: String,
        commits: [Commit]
    ) -> String {
        var parts: [String] = []
        parts.append("Pull Request: \(title)")

        if !body.isEmpty {
            let trimmed = String(body.prefix(800))
            parts.append("\nDescription:\n\(trimmed)")
        }

        if !commits.isEmpty {
            parts.append("\nCommits (\(commits.count) total):")
            for commit in commits {
                parts.append("- \(commit.message.components(separatedBy: "\n").first ?? commit.message)")
            }
        }

        parts.append("")
        parts.append("""
        이 PR의 내용을 한국어로 요약해주세요.
        규칙:
        - 문장 형태로 작성 (불릿 포인트 사용 금지)
        - 모든 커밋의 변경 사항을 빠짐없이 포함해서 설명
        - 커밋이 많으면 관련 있는 것끼리 묶어서 설명
        - 3~5문장으로 작성
        - 마크다운 서식(**, *, #, - 등) 사용 금지, 순수 텍스트만
        """)

        return parts.joined(separator: "\n")
    }

    func buildCommitTranslationPrompt(_ message: String) -> String {
        """
        다음 git commit 메시지를 한국어로 번역해주세요.
        규칙:
        - 개발자가 읽기 편하게 간결하고 정확하게 번역
        - 한 문장으로 작성
        - 마크다운 서식 사용 금지, 순수 텍스트만

        Commit: \(message)
        """
    }
}
