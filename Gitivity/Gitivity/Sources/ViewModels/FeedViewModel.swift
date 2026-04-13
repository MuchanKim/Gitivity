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
    private let cache = DataCacheService.shared

    func loadFeed(forceRefresh: Bool = false) async {
        // Check cache first
        if !forceRefresh, let cached: [TimelineItem] = await cache.get(CacheKey.feedItems) {
            feedState = .loaded(cached)
            await restoreAIStatesFromCache(for: cached)
            return
        }

        if case .loaded = feedState {
            // refresh path
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
            await cache.set(CacheKey.feedItems, value: items)

            // Start AI enrichment — check cache per repo
            for item in items {
                let repoName = item.repoFullName
                if let cached: String = await cache.get(CacheKey.aiSummary(repoName)) {
                    aiSummaryStates[repoName] = .loaded(cached)
                } else {
                    aiSummaryStates[repoName] = .loading
                }
                if let cached: [CommitCategory: Int] = await cache.get(CacheKey.categoryDistribution(repoName)) {
                    categoryStates[repoName] = .loaded(cached)
                } else {
                    categoryStates[repoName] = .loading
                }
            }

            let itemsNeedingAI = items.filter { item in
                if case .loaded = aiSummaryStates[item.repoFullName] { return false }
                return true
            }

            if !itemsNeedingAI.isEmpty {
                await enrichWithAI(itemsNeedingAI)
            }
        } catch {
            if let apiError = error as? GitHubAPIError, case .httpError(401) = apiError {
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

    private func restoreAIStatesFromCache(for items: [TimelineItem]) async {
        for item in items {
            let repoName = item.repoFullName
            if let summary: String = await cache.get(CacheKey.aiSummary(repoName)) {
                aiSummaryStates[repoName] = .loaded(summary)
            }
            if let dist: [CommitCategory: Int] = await cache.get(CacheKey.categoryDistribution(repoName)) {
                categoryStates[repoName] = .loaded(dist)
            }
        }
    }

    private func enrichWithAI(_ items: [TimelineItem]) async {
        let provider = FoundationProvider()
        let promptBuilder = self.promptBuilder
        let classifier = self.classifier
        let cache = self.cache

        await withTaskGroup(of: (String, Result<String, Error>, [CommitCategory: Int]).self) { group in
            for item in items {
                group.addTask {
                    let messages = item.commits.map(\.message)
                    let categories = await classifier.classifyBatch(messages)
                    var distribution: [CommitCategory: Int] = [:]
                    for category in categories {
                        distribution[category, default: 0] += 1
                    }

                    let prompt = promptBuilder.buildRepoSummaryPrompt(
                        repoName: item.repositoryName,
                        pullRequests: item.pullRequests,
                        commits: item.commits
                    )
                    do {
                        let summary = try await provider.summarize(prompt: prompt)
                        // Cache results
                        await cache.set(CacheKey.aiSummary(item.repoFullName), value: summary)
                        await cache.set(CacheKey.categoryDistribution(item.repoFullName), value: distribution)
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
