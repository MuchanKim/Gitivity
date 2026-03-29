import Foundation

struct RepoDetailItem: Sendable, Identifiable {
    let id: String
    let type: RepoDetailItemType
    let title: String
    let aiSummary: String?
    let timestamp: Date
    let additions: Int
    let deletions: Int
    let commits: [ClassifiedCommit]
}

enum RepoDetailItemType: Sendable {
    case pullRequest(number: Int, merged: Bool)
    case commit(hash: String)
}

struct ClassifiedCommit: Sendable, Identifiable {
    let id: String
    let originalMessage: String
    let translatedMessage: String?
    let category: CommitCategory
    let additions: Int
    let deletions: Int
    let timestamp: Date
}
