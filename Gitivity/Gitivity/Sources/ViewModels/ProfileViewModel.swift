import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var profileState: LoadingState<ProfileData> = .loading
    private(set) var categoryState: LoadingState<[CommitCategory: Int]> = .loading
    private(set) var isRetrying = false

    private let keychain = KeychainService()
    private let classifier = CommitClassifier(aiProvider: FoundationProvider())

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
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!

            async let viewer = api.fetchViewer()
            async let contribs = api.fetchContributions(from: thirtyDaysAgo, to: now)
            async let prs = api.fetchPullRequests(limit: 20)
            async let commits = api.fetchCommits(limit: 30)

            let (fetchedUser, fetchedContribs, fetchedPRs, fetchedCommits) = try await (viewer, contribs, prs, commits)

            let data = ProfileData(
                user: fetchedUser,
                contributions: fetchedContribs,
                totalCommits: fetchedCommits.count,
                totalPRs: fetchedPRs.count,
                activeRepos: Set(fetchedCommits.map(\.repositoryName).filter { !$0.isEmpty }).count
            )
            isRetrying = false
            profileState = .loaded(data)

            // AI classification independently
            categoryState = .loading
            let messages = fetchedCommits.map(\.message)
            let categories = await classifier.classifyBatch(messages)
            var dist: [CommitCategory: Int] = [:]
            for cat in categories { dist[cat, default: 0] += 1 }
            categoryState = .loaded(dist)
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
