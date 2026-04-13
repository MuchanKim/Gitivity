import Foundation

enum ProfilePeriod: Int, CaseIterable, Identifiable {
    case oneMonth = 30
    case threeMonths = 90
    case sixMonths = 180
    case oneYear = 365

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .oneMonth: "1개월"
        case .threeMonths: "3개월"
        case .sixMonths: "6개월"
        case .oneYear: "1년"
        }
    }
}

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var profileState: LoadingState<ProfileData> = .loading
    private(set) var categoryState: LoadingState<[CommitCategory: Int]> = .loading
    private(set) var badges: [DeveloperBadge] = []
    private(set) var isRetrying = false
    var selectedPeriod: ProfilePeriod = .sixMonths

    private let keychain = KeychainService()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())
    private let cache = DataCacheService.shared

    var categoryDistribution: [CommitCategory: Int] {
        if case .loaded(let dist) = categoryState { return dist }
        return [:]
    }

    func load(forceRefresh: Bool = false) async {
        let periodDays = selectedPeriod.rawValue

        // Check cache first
        if !forceRefresh,
           let cachedData: ProfileData = await cache.get(CacheKey.profileData(periodDays)),
           let cachedBadges: [DeveloperBadge] = await cache.get(CacheKey.profileBadges(periodDays)) {
            profileState = .loaded(cachedData)
            badges = cachedBadges

            if let cachedCats: [CommitCategory: Int] = await cache.get(CacheKey.profileCategories(periodDays)) {
                categoryState = .loaded(cachedCats)
            }
            return
        }

        if case .loaded = profileState {
            // refresh path
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
            let statsStart = Calendar.current.date(byAdding: .day, value: -periodDays, to: now) ?? now
            let gridStart = Calendar.current.date(byAdding: .day, value: -180, to: now) ?? now

            async let viewer = api.fetchViewer()
            async let stats = api.fetchContributionStats(from: statsStart, to: now)
            async let gridContributions = api.fetchContributions(from: gridStart, to: now)
            async let stars = api.fetchTotalStars()
            async let commits = api.fetchCommits(limit: 100)

            let (fetchedUser, fetchedStats, fetchedGrid, fetchedStars, fetchedCommits) = try await (viewer, stats, gridContributions, stars, commits)

            let data = ProfileData(
                user: fetchedUser,
                contributions: fetchedGrid,
                totalCommits: fetchedStats.totalCommits,
                totalPRs: fetchedStats.totalPRs,
                totalReviews: fetchedStats.totalReviews,
                totalIssues: fetchedStats.totalIssues,
                activeRepos: Set(fetchedCommits.map(\.repositoryName).filter { !$0.isEmpty }).count,
                totalStars: fetchedStars.totalStars,
                topRepoName: fetchedStars.topRepoName,
                topRepoStars: fetchedStars.topRepoStars,
                commits: fetchedCommits,
                currentStreak: ProfileData.calculateStreak(from: fetchedGrid)
            )
            isRetrying = false
            profileState = .loaded(data)
            badges = BadgeCalculator.calculate(from: data)

            // Cache profile data
            await cache.set(CacheKey.profileData(periodDays), value: data)
            await cache.set(CacheKey.profileBadges(periodDays), value: badges)

            // AI classification — check cache
            if let cachedCats: [CommitCategory: Int] = await cache.get(CacheKey.profileCategories(periodDays)) {
                categoryState = .loaded(cachedCats)
            } else {
                categoryState = .loading
                let messages = fetchedCommits.map(\.message)
                let categories = await classifier.classifyBatch(messages)
                var dist: [CommitCategory: Int] = [:]
                for cat in categories { dist[cat, default: 0] += 1 }
                categoryState = .loaded(dist)
                await cache.set(CacheKey.profileCategories(periodDays), value: dist)
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
