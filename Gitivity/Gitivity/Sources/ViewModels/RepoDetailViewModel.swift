import Foundation

@Observable
final class RepoDetailViewModel {
    private(set) var repoSummary: String?
    private(set) var detailItems: [RepoDetailItem] = []
    private(set) var categoryDistribution: [CommitCategory: Int] = [:]
    private(set) var isLoading = false

    private let promptBuilder = ActivityPromptBuilder()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())

    func load(from timelineItem: TimelineItem) async {
        isLoading = true
        defer { isLoading = false }

        categoryDistribution = timelineItem.categoryDistribution
        repoSummary = timelineItem.aiSummary

        let provider = FoundationProvider()
        var items: [RepoDetailItem] = []

        // PR items with AI summaries
        for pr in timelineItem.pullRequests.sorted(by: { $0.createdAt > $1.createdAt }) {
            let prCommits = timelineItem.commits.filter { commit in
                commit.committedDate >= pr.createdAt.addingTimeInterval(-86400 * 7) &&
                commit.committedDate <= (pr.mergedAt ?? pr.createdAt)
            }

            let classifiedCommits = await Self.classifyAndTranslate(
                prCommits,
                provider: provider,
                classifier: classifier,
                promptBuilder: promptBuilder
            )

            let prompt = promptBuilder.buildPRSummaryPrompt(
                title: pr.title,
                body: pr.body,
                commits: prCommits
            )
            let summary = try? await provider.summarize(prompt: prompt)

            items.append(RepoDetailItem(
                id: pr.id,
                type: .pullRequest(number: Self.extractPRNumber(pr.title), merged: pr.mergedAt != nil),
                title: pr.title,
                aiSummary: summary,
                timestamp: pr.createdAt,
                additions: pr.additions,
                deletions: pr.deletions,
                commits: classifiedCommits
            ))
        }

        // Standalone commits (not in any PR)
        let prCommitIDs = Set(items.flatMap { $0.commits.map(\.id) })
        let standaloneCommits = timelineItem.commits.filter { !prCommitIDs.contains($0.id) }

        for commit in standaloneCommits.sorted(by: { $0.committedDate > $1.committedDate }) {
            let classified = await Self.classifyAndTranslate(
                [commit],
                provider: provider,
                classifier: classifier,
                promptBuilder: promptBuilder
            )
            guard let c = classified.first else { continue }

            items.append(RepoDetailItem(
                id: commit.id,
                type: .commit(hash: String(commit.id.prefix(7))),
                title: commit.message.components(separatedBy: "\n").first ?? commit.message,
                aiSummary: c.translatedMessage,
                timestamp: commit.committedDate,
                additions: commit.additions,
                deletions: commit.deletions,
                commits: []
            ))
        }

        detailItems = items.sorted { $0.timestamp > $1.timestamp }
    }

    nonisolated private static func classifyAndTranslate(
        _ commits: [Commit],
        provider: FoundationProvider,
        classifier: CommitClassifier,
        promptBuilder: ActivityPromptBuilder
    ) async -> [ClassifiedCommit] {
        await withTaskGroup(of: ClassifiedCommit.self) { group in
            for commit in commits {
                group.addTask {
                    let category = await classifier.classify(commit.message)
                    let prompt = promptBuilder.buildCommitTranslationPrompt(commit.message)
                    let translation = try? await provider.summarize(prompt: prompt)

                    return ClassifiedCommit(
                        id: commit.id,
                        originalMessage: commit.message,
                        translatedMessage: translation,
                        category: category,
                        additions: commit.additions,
                        deletions: commit.deletions,
                        timestamp: commit.committedDate
                    )
                }
            }

            var results: [ClassifiedCommit] = []
            for await result in group {
                results.append(result)
            }
            return results.sorted { $0.timestamp > $1.timestamp }
        }
    }

    nonisolated private static func extractPRNumber(_ title: String) -> Int {
        if let match = title.firstMatch(of: /#(\d+)/) {
            return Int(match.1) ?? 0
        }
        return 0
    }
}
