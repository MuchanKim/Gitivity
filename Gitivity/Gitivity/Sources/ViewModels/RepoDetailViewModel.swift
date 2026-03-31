import Foundation
import os

@MainActor
@Observable
final class RepoDetailViewModel {
    private(set) var detailState: LoadingState<[RepoDetailItem]> = .loading
    private(set) var repoAISummary: LoadingState<String> = .loading
    private(set) var categoryDistribution: [CommitCategory: Int] = [:]
    private(set) var itemAISummaries: [String: LoadingState<String>] = [:]

    private let promptBuilder = ActivityPromptBuilder()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())

    func load(from timelineItem: TimelineItem, feedAISummary: LoadingState<String>, feedCategory: LoadingState<[CommitCategory: Int]>) async {
        // Inherit AI state from feed
        repoAISummary = feedAISummary
        if case .loaded(let dist) = feedCategory {
            categoryDistribution = dist
        }

        let provider = FoundationProvider()
        var items: [RepoDetailItem] = []

        // PR items
        for pr in timelineItem.pullRequests.sorted(by: { $0.createdAt > $1.createdAt }) {
            let prCommits = timelineItem.commits.filter { commit in
                commit.committedDate >= pr.createdAt.addingTimeInterval(-86400 * 7) &&
                commit.committedDate <= (pr.mergedAt ?? pr.createdAt)
            }

            let classifiedCommits = await Self.classifyCommits(
                prCommits,
                classifier: classifier,
                promptBuilder: promptBuilder
            )

            itemAISummaries[pr.id] = .loading
            items.append(RepoDetailItem(
                id: pr.id,
                type: .pullRequest(number: Self.extractPRNumber(pr.title), merged: pr.mergedAt != nil),
                title: pr.title,
                aiSummary: nil,
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
            let classified = await Self.classifyCommits(
                [commit],
                classifier: classifier,
                promptBuilder: promptBuilder
            )
            guard let c = classified.first else { continue }

            items.append(RepoDetailItem(
                id: commit.id,
                type: .commit(hash: String(commit.id.prefix(7))),
                title: commit.message.components(separatedBy: "\n").first ?? commit.message,
                aiSummary: nil,
                timestamp: commit.committedDate,
                additions: commit.additions,
                deletions: commit.deletions,
                commits: []
            ))
            // Commit translation is already done in classifyCommits
            itemAISummaries[commit.id] = .loaded(c.translatedMessage ?? commit.message)
        }

        detailState = .loaded(items.sorted { $0.timestamp > $1.timestamp })

        // Generate PR AI summaries independently
        await generatePRAISummaries(items: items, timelineItem: timelineItem, provider: provider)
    }

    private func generatePRAISummaries(items: [RepoDetailItem], timelineItem: TimelineItem, provider: FoundationProvider) async {
        await withTaskGroup(of: (String, String?).self) { group in
            for item in items {
                guard case .pullRequest = item.type else { continue }

                group.addTask { [promptBuilder] in
                    let prompt = promptBuilder.buildPRSummaryPrompt(
                        title: item.title,
                        body: "",
                        commits: timelineItem.commits
                    )
                    var summary: String?
                    do {
                        summary = try await provider.summarize(prompt: prompt)
                    } catch {
                        AILogger.generation.error("[RepoDetail] PR summary failed for \(item.title): \(error)")
                    }
                    return (item.id, summary)
                }
            }

            for await (itemId, summary) in group {
                if let summary {
                    itemAISummaries[itemId] = .loaded(summary)
                } else {
                    itemAISummaries[itemId] = .error(AIProviderError.generationFailed(underlying: NSError(domain: "AI", code: -1)))
                }
            }
        }
    }

    nonisolated private static func classifyCommits(
        _ commits: [Commit],
        classifier: CommitClassifier,
        promptBuilder: ActivityPromptBuilder
    ) async -> [ClassifiedCommit] {
        await withTaskGroup(of: ClassifiedCommit.self) { group in
            for commit in commits {
                group.addTask {
                    let category = await classifier.classify(commit.message)
                    let prompt = promptBuilder.buildCommitTranslationPrompt(commit.message)
                    var translation: String?
                    do {
                        translation = try await FoundationProvider().summarize(prompt: prompt)
                    } catch {
                        AILogger.generation.error("[RepoDetail] commit translation failed: \(error)")
                    }

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
