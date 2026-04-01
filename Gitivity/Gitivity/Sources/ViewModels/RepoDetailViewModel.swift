import Foundation
import os

@MainActor
@Observable
final class RepoDetailViewModel {
    private(set) var detailItems: [RepoDetailItem] = []
    private(set) var itemAISummaries: [String: LoadingState<String>] = [:]

    private let promptBuilder = ActivityPromptBuilder()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())

    func load(from timelineItem: TimelineItem) async {
        let provider = FoundationProvider()
        var items: [RepoDetailItem] = []

        // PR items — build immediately
        for pr in timelineItem.pullRequests.sorted(by: { $0.createdAt > $1.createdAt }) {
            let prCommits = timelineItem.commits.filter { commit in
                commit.committedDate >= pr.createdAt.addingTimeInterval(-86400 * 7) &&
                commit.committedDate <= (pr.mergedAt ?? pr.createdAt)
            }

            let classifiedCommits = await Self.classifyCommits(
                prCommits,
                classifier: classifier
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

        // Standalone commits
        let prCommitIDs = Set(items.flatMap { $0.commits.map(\.id) })
        let standaloneCommits = timelineItem.commits.filter { !prCommitIDs.contains($0.id) }

        for commit in standaloneCommits.sorted(by: { $0.committedDate > $1.committedDate }) {
            let category = await classifier.classify(commit.message)

            itemAISummaries[commit.id] = .loading
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
        }

        detailItems = items.sorted { $0.timestamp > $1.timestamp }

        // AI summaries — async, independent per item
        await generateAISummaries(
            items: detailItems,
            timelineItem: timelineItem,
            provider: provider
        )
    }

    private func generateAISummaries(
        items: [RepoDetailItem],
        timelineItem: TimelineItem,
        provider: FoundationProvider
    ) async {
        let prMap = Dictionary(uniqueKeysWithValues: timelineItem.pullRequests.map { ($0.id, $0) })

        await withTaskGroup(of: (String, Result<String, Error>).self) { group in
            for item in items {
                switch item.type {
                case .pullRequest:
                    let pr = prMap[item.id]
                    let prCommits = item.commits.map { classified in
                        timelineItem.commits.first { $0.id == classified.id }
                    }.compactMap { $0 }

                    group.addTask { [promptBuilder] in
                        let prompt = promptBuilder.buildPRSummaryPrompt(
                            title: item.title,
                            body: pr?.body ?? "",
                            commits: prCommits
                        )
                        do {
                            let summary = try await provider.summarize(prompt: prompt)
                            return (item.id, .success(summary))
                        } catch {
                            AILogger.generation.error("[RepoDetail] PR summary failed for \(item.title): \(error)")
                            return (item.id, .failure(error))
                        }
                    }

                case .commit:
                    group.addTask { [promptBuilder] in
                        let prompt = promptBuilder.buildCommitDescriptionPrompt(item.title)
                        do {
                            let description = try await provider.summarize(prompt: prompt)
                            return (item.id, .success(description))
                        } catch {
                            AILogger.generation.error("[RepoDetail] commit desc failed for \(item.title): \(error)")
                            return (item.id, .failure(error))
                        }
                    }
                }
            }

            for await (itemId, result) in group {
                switch result {
                case .success(let text):
                    itemAISummaries[itemId] = .loaded(text)
                case .failure(let error):
                    itemAISummaries[itemId] = .error(error)
                }
            }
        }
    }

    nonisolated private static func classifyCommits(
        _ commits: [Commit],
        classifier: CommitClassifier
    ) async -> [ClassifiedCommit] {
        await withTaskGroup(of: ClassifiedCommit.self) { group in
            for commit in commits {
                group.addTask {
                    let category = await classifier.classify(commit.message)
                    return ClassifiedCommit(
                        id: commit.id,
                        originalMessage: commit.message,
                        translatedMessage: nil,
                        category: category,
                        additions: commit.additions,
                        deletions: commit.deletions,
                        timestamp: commit.committedDate
                    )
                }
            }
            var results: [ClassifiedCommit] = []
            for await result in group { results.append(result) }
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
