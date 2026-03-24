import Foundation

struct ContributionDay: Sendable, Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let level: Int
}

struct PullRequest: Sendable, Identifiable {
    let id: String
    let title: String
    let body: String
    let url: String
    let createdAt: Date
    let mergedAt: Date?
    let additions: Int
    let deletions: Int
    let changedFiles: Int
    let repositoryName: String
}

struct Commit: Sendable, Identifiable {
    let id: String
    let message: String
    let url: String
    let committedDate: Date
    let additions: Int
    let deletions: Int
    let repositoryName: String
}

struct Issue: Sendable, Identifiable {
    let id: String
    let title: String
    let body: String
    let url: String
    let createdAt: Date
    let closedAt: Date?
    let repositoryName: String
}
