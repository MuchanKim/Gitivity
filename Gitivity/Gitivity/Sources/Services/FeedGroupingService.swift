import Foundation

struct FeedGroupingService: Sendable {
    func groupIntoTimeline(
        pullRequests: [PullRequest],
        commits: [Commit],
        issues: [Issue]
    ) -> [TimelineItem] {
        let allRepos = Set(
            pullRequests.map(\.repositoryName) +
            commits.map(\.repositoryName)
        )

        return allRepos.map { repoName in
            let repoPRs = pullRequests.filter { $0.repositoryName == repoName }
            let repoCommits = commits.filter { $0.repositoryName == repoName }

            let latestDate = ([repoPRs.map(\.createdAt), repoCommits.map(\.committedDate)]
                .flatMap { $0 })
                .max() ?? Date.distantPast

            let parts = repoName.split(separator: "/")
            let owner = parts.count > 1 ? String(parts[0]) : ""

            return TimelineItem(
                id: repoName,
                repositoryName: repoName,
                repositoryOwner: owner,
                lastActivityDate: latestDate,
                pullRequests: repoPRs,
                commits: repoCommits,
                aiSummary: nil,
                categoryDistribution: [:]
            )
        }
        .sorted { $0.lastActivityDate > $1.lastActivityDate }
    }
}
