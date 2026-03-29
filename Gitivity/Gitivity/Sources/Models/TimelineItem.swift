import Foundation

struct TimelineItem: Sendable, Identifiable {
    let id: String
    let repositoryName: String
    let repositoryOwner: String
    let lastActivityDate: Date
    let pullRequests: [PullRequest]
    let commits: [Commit]
    let aiSummary: String?
    let categoryDistribution: [CommitCategory: Int]

    var totalAdditions: Int {
        pullRequests.reduce(0) { $0 + $1.additions } +
        commits.reduce(0) { $0 + $1.additions }
    }

    var totalDeletions: Int {
        pullRequests.reduce(0) { $0 + $1.deletions } +
        commits.reduce(0) { $0 + $1.deletions }
    }

    var prCount: Int { pullRequests.count }
    var commitCount: Int { commits.count }
}

extension TimelineItem: Hashable {
    static func == (lhs: TimelineItem, rhs: TimelineItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
