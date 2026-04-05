import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var profileState: LoadingState<ProfileData> = .loading
    private(set) var categoryState: LoadingState<[CommitCategory: Int]> = .loading
    private(set) var badges: [DeveloperBadge] = []
    private(set) var isRetrying = false

    private let keychain = KeychainService()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())

    var categoryDistribution: [CommitCategory: Int] {
        if case .loaded(let dist) = categoryState { return dist }
        return [:]
    }

    func load() async {
        if case .loaded = profileState {
            // refresh — keep existing data visible
        } else if case .error = profileState {
            isRetrying = true
        } else {
            profileState = .loading
        }

        guard let token = try? keychain.read(key: "github_token") else {
            profileState = .error(AuthError.noCode)
            return
        }

        let api = GitHubGraphQLService(accessToken: token)

        do {
            let now = Date()
            let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: now)!

            async let viewer = api.fetchViewer()
            async let stats = api.fetchContributionStats(from: ninetyDaysAgo, to: now)
            async let stars = api.fetchTotalStars()
            async let commits = api.fetchCommits(limit: 100)

            let (fetchedUser, fetchedStats, fetchedStars, fetchedCommits) = try await (viewer, stats, stars, commits)

            let data = ProfileData(
                user: fetchedUser,
                contributions: fetchedStats.contributions,
                totalCommits: fetchedStats.totalCommits,
                totalPRs: fetchedStats.totalPRs,
                totalReviews: fetchedStats.totalReviews,
                totalIssues: fetchedStats.totalIssues,
                activeRepos: Set(fetchedCommits.map(\.repositoryName).filter { !$0.isEmpty }).count,
                totalStars: fetchedStars.totalStars,
                topRepoName: fetchedStars.topRepoName,
                topRepoStars: fetchedStars.topRepoStars,
                commits: fetchedCommits,
                currentStreak: ProfileData.calculateStreak(from: fetchedStats.contributions)
            )
            isRetrying = false
            profileState = .loaded(data)
            badges = BadgeCalculator.calculate(from: data)

            // AI classification independently — 별도 에러 처리
            categoryState = .loading
            do {
                let messages = fetchedCommits.map(\.message)
                let categories = await classifier.classifyBatch(messages)
                var dist: [CommitCategory: Int] = [:]
                for cat in categories { dist[cat, default: 0] += 1 }
                categoryState = .loaded(dist)
            } catch {
                categoryState = .error(error)
            }
        } catch {
            isRetrying = false
            if case .loaded = profileState {
                // refresh failure — keep old data
            } else {
                profileState = .error(error)
            }
        }
    }
}
