import Foundation
import os

@MainActor
@Observable
final class FeedViewModel {
    private(set) var feedState: LoadingState<[TimelineItem]> = .loading
    private(set) var aiSummaryStates: [String: LoadingState<String>] = [:]
    private(set) var categoryStates: [String: LoadingState<[CommitCategory: Int]>] = [:]
    private(set) var isRetrying = false

    private let keychain = KeychainService()
    private let groupingService = FeedGroupingService()
    private let promptBuilder = ActivityPromptBuilder()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())

    func loadFeed() async {
        // Refresh: keep existing data visible
        // Retry from error: keep error screen, show spinner on button
        if case .loaded = feedState {
            // refresh path — don't reset to .loading
        } else if case .error = feedState {
            isRetrying = true
        } else {
            feedState = .loading
        }

        guard let token = try? keychain.read(key: "github_token") else {
            feedState = .error(AuthError.noCode)
            return
        }

        let api = GitHubGraphQLService(accessToken: token)

        do {
            async let prs = api.fetchPullRequests(limit: 20)
            async let issues = api.fetchIssues(limit: 20)
            async let commits = api.fetchCommits(limit: 30)

            let (fetchedPRs, fetchedIssues, fetchedCommits) = try await (prs, issues, commits)

            let items = groupingService.groupIntoTimeline(
                pullRequests: fetchedPRs,
                commits: fetchedCommits,
                issues: fetchedIssues
            )

            isRetrying = false
            feedState = .loaded(items)

            // Start AI enrichment independently
            for item in items {
                aiSummaryStates[item.repoFullName] = .loading
                categoryStates[item.repoFullName] = .loading
            }
            await enrichWithAI(items)
        } catch {
            if let apiError = error as? GitHubAPIError, case .httpError(401) = apiError {
                // Token expired — clear token so AuthViewModel detects it
                try? KeychainService().delete(key: "github_token")
                isRetrying = false
                feedState = .error(error)
                return
            }
            isRetrying = false
            if case .loaded = feedState {
                // refresh failure — keep old data
            } else {
                feedState = .error(error)
            }
        }
    }

    private func enrichWithAI(_ items: [TimelineItem]) async {
        let provider = FoundationProvider()
        let promptBuilder = self.promptBuilder
        let classifier = self.classifier

        await withTaskGroup(of: (String, Result<String, Error>, [CommitCategory: Int]).self) { group in
            for item in items {
                group.addTask {
                    // 1. Classify commits (항상 수행 — ActivityBarView용)
                    let messages = item.commits.map(\.message)
                    let categories = await classifier.classifyBatch(messages)

                    var distribution: [CommitCategory: Int] = [:]
                    var categorizedCommits: [CommitCategory: [String]] = [:]
                    for (message, category) in zip(messages, categories) {
                        distribution[category, default: 0] += 1
                        categorizedCommits[category, default: []].append(message)
                    }

                    // 2. AI summary — PR + 카테고리 데이터 전달
                    let prompt = promptBuilder.buildRepoSummaryPrompt(
                        repoName: item.repositoryName,
                        pullRequests: item.pullRequests,
                        categorizedCommits: categorizedCommits
                    )
                    do {
                        let summary = try await provider.summarize(prompt: prompt)
                        return (item.repoFullName, .success(summary), distribution)
                    } catch {
                        AILogger.generation.error("[Feed] summary failed for \(item.repositoryName): \(error)")
                        return (item.repoFullName, .failure(error), distribution)
                    }
                }
            }

            for await (repoName, result, distribution) in group {
                switch result {
                case .success(let summary):
                    aiSummaryStates[repoName] = .loaded(summary)
                case .failure(let error):
                    aiSummaryStates[repoName] = .error(error)
                }
                categoryStates[repoName] = .loaded(distribution)
            }
        }
    }

}
