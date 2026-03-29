import Foundation

struct FeedItem: Sendable, Identifiable, Hashable {
    let id: String
    let type: FeedItemType
    let title: String
    let repositoryName: String
    let timestamp: Date
    let additions: Int
    let deletions: Int
    let commits: [Commit]
    let aiSummary: String?

    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum FeedItemType: Sendable {
    case pullRequest
    case push
    case issue
}
