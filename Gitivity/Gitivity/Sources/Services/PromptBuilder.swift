import Foundation

struct PromptBuilder: Sendable {
    func buildFeedItemPrompt(item: FeedItem) -> String {
        // TODO: 피드 아이템 → AI 프롬프트
        return ""
    }

    func buildSummaryPrompt(
        period: SummaryPeriod,
        pullRequests: [PullRequest],
        commits: [Commit],
        issues: [Issue]
    ) -> String {
        // TODO: 기간별 요약 프롬프트
        return ""
    }
}
