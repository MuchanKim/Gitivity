import Foundation

struct RepoDetailItem: Sendable, Identifiable {
    let id: String
    let type: RepoDetailItemType
    let title: String
    let body: String
    let url: String
    let aiSummary: String?
    let timestamp: Date
    let additions: Int
    let deletions: Int
    let changedFiles: Int
    let commits: [ClassifiedCommit]
}

extension RepoDetailItem: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum RepoDetailItemType: Sendable, Hashable {
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

    var commitTitle: String {
        originalMessage.components(separatedBy: "\n").first ?? originalMessage
    }

    var commitBody: String? {
        guard let range = originalMessage.range(of: "\n\n") else { return nil }
        let body = String(originalMessage[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        return body.isEmpty ? nil : body
    }
}
