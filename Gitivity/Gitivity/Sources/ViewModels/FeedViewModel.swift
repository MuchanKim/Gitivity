import Foundation

@Observable
final class FeedViewModel {
    private(set) var timelineItems: [TimelineItem] = []
    private(set) var isLoading = false
    var error: String?

    private let keychain = KeychainService()
    private let groupingService = FeedGroupingService()
    private let promptBuilder = ActivityPromptBuilder()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())

    func loadFeed() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        guard let token = try? keychain.read(key: "github_token") else {
            error = "로그인이 필요합니다."
            return
        }

        let api = GitHubGraphQLService(accessToken: token)

        do {
            async let prs = api.fetchPullRequests(limit: 20)
            async let issues = api.fetchIssues(limit: 20)
            async let commits = api.fetchCommits(limit: 30)

            let (fetchedPRs, fetchedIssues, fetchedCommits) = try await (prs, issues, commits)

            var items = groupingService.groupIntoTimeline(
                pullRequests: fetchedPRs,
                commits: fetchedCommits,
                issues: fetchedIssues
            )

            // Classify commits and generate AI summaries
            items = await enrichWithAI(items)

            timelineItems = items
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func enrichWithAI(_ items: [TimelineItem]) async -> [TimelineItem] {
        let provider = FoundationProvider()
        let promptBuilder = self.promptBuilder
        let classifier = self.classifier

        return await withTaskGroup(of: (Int, TimelineItem).self) { group in
            for (index, item) in items.enumerated() {
                group.addTask {
                    var enriched = item

                    // Classify commits
                    let messages = item.commits.map(\.message)
                    let categories = await classifier.classifyBatch(messages)
                    var distribution: [CommitCategory: Int] = [:]
                    for category in categories {
                        distribution[category, default: 0] += 1
                    }
                    enriched = TimelineItem(
                        id: item.id,
                        repositoryName: item.repositoryName,
                        repositoryOwner: item.repositoryOwner,
                        lastActivityDate: item.lastActivityDate,
                        pullRequests: item.pullRequests,
                        commits: item.commits,
                        aiSummary: item.aiSummary,
                        categoryDistribution: distribution
                    )

                    // Generate AI summary
                    let prompt = promptBuilder.buildRepoSummaryPrompt(
                        repoName: item.repositoryName,
                        pullRequests: item.pullRequests,
                        commits: item.commits
                    )
                    if let summary = try? await provider.summarize(prompt: prompt) {
                        enriched = TimelineItem(
                            id: enriched.id,
                            repositoryName: enriched.repositoryName,
                            repositoryOwner: enriched.repositoryOwner,
                            lastActivityDate: enriched.lastActivityDate,
                            pullRequests: enriched.pullRequests,
                            commits: enriched.commits,
                            aiSummary: summary,
                            categoryDistribution: enriched.categoryDistribution
                        )
                    }

                    return (index, enriched)
                }
            }

            var results = [(Int, TimelineItem)]()
            for await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map(\.1)
        }
    }
}
