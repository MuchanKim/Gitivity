import Foundation

struct FeedGroupingService: Sendable {
    func groupIntoFeedItems(
        pullRequests: [PullRequest],
        commits: [Commit],
        issues: [Issue]
    ) -> [FeedItem] {
        var items: [FeedItem] = []

        for pr in pullRequests {
            items.append(FeedItem(
                id: pr.id,
                type: .pullRequest,
                title: pr.title,
                repositoryName: pr.repositoryName,
                timestamp: pr.createdAt,
                additions: pr.additions,
                deletions: pr.deletions,
                commits: [],
                aiSummary: nil
            ))
        }

        for issue in issues {
            items.append(FeedItem(
                id: issue.id,
                type: .issue,
                title: issue.title,
                repositoryName: issue.repositoryName,
                timestamp: issue.createdAt,
                additions: 0,
                deletions: 0,
                commits: [],
                aiSummary: nil
            ))
        }

        let commitsByRepo = Dictionary(grouping: commits) { $0.repositoryName }
        for (repo, repoCommits) in commitsByRepo {
            let sorted = repoCommits.sorted { $0.committedDate > $1.committedDate }
            let totalAdditions = sorted.reduce(0) { $0 + $1.additions }
            let totalDeletions = sorted.reduce(0) { $0 + $1.deletions }
            let latest = sorted[0]

            items.append(FeedItem(
                id: "push-\(repo)-\(latest.id)",
                type: .push,
                title: "\(sorted.count)개의 커밋 — \(repo)",
                repositoryName: repo,
                timestamp: latest.committedDate,
                additions: totalAdditions,
                deletions: totalDeletions,
                commits: sorted,
                aiSummary: nil
            ))
        }

        return items.sorted { $0.timestamp > $1.timestamp }
    }
}
