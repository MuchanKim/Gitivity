import Foundation

struct FeedItem: Sendable, Identifiable {
    let id: String
    let type: FeedItemType
    let title: String
    let repositoryName: String
    let timestamp: Date
    let additions: Int
    let deletions: Int
    let commits: [Commit]
    let aiSummary: String?
}

enum FeedItemType: Sendable {
    case pullRequest
    case push
    case issue
}
