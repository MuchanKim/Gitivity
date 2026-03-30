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
            parts.append("Recent Pull Requests:")
            for pr in pullRequests.prefix(10) {
                parts.append("- \(pr.title)")
            }
        }

        if !commits.isEmpty {
            parts.append("Recent Commits:")
            for commit in commits.prefix(15) {
                parts.append("- \(commit.message.components(separatedBy: "\n").first ?? commit.message)")
            }
        }

        parts.append("")
        parts.append("위 GitHub 활동을 한국어 2~3문장으로 요약해주세요. 어떤 작업을 했는지 사람이 이해할 수 있게 설명해주세요.")

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
            let trimmed = String(body.prefix(500))
            parts.append("Description: \(trimmed)")
        }

        if !commits.isEmpty {
            parts.append("Commits:")
            for commit in commits.prefix(10) {
                parts.append("- \(commit.message.components(separatedBy: "\n").first ?? commit.message)")
            }
        }

        parts.append("")
        parts.append("이 PR이 무엇을 했는지 한국어 1~2문장으로 요약해주세요.")

        return parts.joined(separator: "\n")
    }

    func buildCommitTranslationPrompt(_ message: String) -> String {
        "다음 git commit 메시지를 한국어로 번역해주세요. 개발자가 아닌 사람도 이해할 수 있게 자연스럽게 설명해주세요. 한 문장으로 답변해주세요.\n\nCommit: \(message)"
    }
}
