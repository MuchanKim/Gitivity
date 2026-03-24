import Foundation

struct FeedGroupingService: Sendable {
    func groupIntoFeedItems(
        pullRequests: [PullRequest],
        commits: [Commit],
        issues: [Issue]
    ) -> [FeedItem] {
        // TODO: PR 단위 그룹핑, PR 없는 커밋은 브랜치+시간 근접성 기준 그룹핑
        return []
    }
}
