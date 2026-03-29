import Foundation

@Observable
final class ProfileViewModel {
    private(set) var user: GitHubUser?
    private(set) var contributions: [ContributionDay] = []
    private(set) var totalCommits = 0
    private(set) var totalPRs = 0
    private(set) var activeRepos = 0
    private(set) var categoryDistribution: [CommitCategory: Int] = [:]
    private(set) var isLoading = false

    private let keychain = KeychainService()
    private let classifier = CommitClassifier()

    func load() async {
        isLoading = true
        defer { isLoading = false }

        guard let token = try? keychain.read(key: "github_token") else { return }

        let api = GitHubGraphQLService(accessToken: token)

        do {
            let now = Date()
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!

            async let viewer = api.fetchViewer()
            async let contribs = api.fetchContributions(from: thirtyDaysAgo, to: now)
            async let prs = api.fetchPullRequests(limit: 20)
            async let commits = api.fetchCommits(limit: 30)

            let (fetchedUser, fetchedContribs, fetchedPRs, fetchedCommits) = try await (viewer, contribs, prs, commits)

            user = fetchedUser
            contributions = fetchedContribs
            totalCommits = fetchedCommits.count
            totalPRs = fetchedPRs.count
            activeRepos = Set(fetchedCommits.map(\.repositoryName).filter { !$0.isEmpty }).count

            // Classify
            let messages = fetchedCommits.map(\.message)
            let categories = await classifier.classifyBatch(messages)
            var dist: [CommitCategory: Int] = [:]
            for cat in categories { dist[cat, default: 0] += 1 }
            categoryDistribution = dist
        } catch {
            // Silent fail — profile shows empty state
        }
    }
}
