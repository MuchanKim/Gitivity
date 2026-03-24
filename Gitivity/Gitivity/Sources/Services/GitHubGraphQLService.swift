import Foundation

struct GitHubGraphQLService: Sendable {
    let accessToken: String

    func fetchContributions(from: Date, to: Date) async throws -> [ContributionDay] {
        // TODO: GitHub GraphQL API - 컨트리뷰션 캘린더
        return []
    }

    func fetchPullRequests(limit: Int) async throws -> [PullRequest] {
        // TODO: GitHub GraphQL API - PR 목록
        return []
    }

    func fetchCommits(limit: Int) async throws -> [Commit] {
        // TODO: GitHub GraphQL API - 커밋 목록
        return []
    }
}
