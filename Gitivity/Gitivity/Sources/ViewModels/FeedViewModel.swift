import Foundation

@Observable
final class FeedViewModel {
    private(set) var feedItems: [FeedItem] = []
    private(set) var isLoading = false
    var error: String?

    private let keychain = KeychainService()
    private let groupingService = FeedGroupingService()

    func loadFeed() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        guard let token = try? keychain.read(key: "github_token") else {
            error = "로그인이 필요합니다."
            return
        }

        let service = GitHubGraphQLService(accessToken: token)

        do {
            async let prs = service.fetchPullRequests(limit: 20)
            async let issues = service.fetchIssues(limit: 20)
            async let commits = service.fetchCommits(limit: 30)

            let (fetchedPRs, fetchedIssues, fetchedCommits) = try await (prs, issues, commits)

            feedItems = groupingService.groupIntoFeedItems(
                pullRequests: fetchedPRs,
                commits: fetchedCommits,
                issues: fetchedIssues
            )
        } catch {
            self.error = error.localizedDescription
        }
    }
}
