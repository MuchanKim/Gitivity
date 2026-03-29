import Foundation

struct GitHubGraphQLService: Sendable {
    let accessToken: String

    // MARK: - Viewer

    func fetchViewer() async throws -> GitHubUser {
        let query = """
        query {
          viewer { login name avatarUrl }
        }
        """
        let result: ViewerResponse = try await execute(query: query)
        let v = result.viewer
        return GitHubUser(login: v.login, name: v.name, avatarURL: v.avatarUrl)
    }

    // MARK: - Contributions

    func fetchContributions(from startDate: Date, to endDate: Date) async throws -> [ContributionDay] {
        let query = """
        query($from: DateTime!, $to: DateTime!) {
          viewer {
            contributionsCollection(from: $from, to: $to) {
              contributionCalendar {
                weeks {
                  contributionDays {
                    date
                    contributionCount
                    contributionLevel
                  }
                }
              }
            }
          }
        }
        """
        let iso = ISO8601DateFormatter()
        let variables: [String: Any] = [
            "from": iso.string(from: startDate),
            "to": iso.string(from: endDate),
        ]
        let result: ContributionsResponse = try await execute(query: query, variables: variables)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "UTC")

        return result.viewer.contributionsCollection.contributionCalendar.weeks
            .flatMap(\.contributionDays)
            .compactMap { day in
                guard let date = df.date(from: day.date) else { return nil }
                return ContributionDay(date: date, count: day.contributionCount, level: day.contributionLevel.numericValue)
            }
    }

    // MARK: - Pull Requests

    func fetchPullRequests(limit: Int = 20) async throws -> [PullRequest] {
        let query = """
        query($limit: Int!) {
          viewer {
            pullRequests(first: $limit, orderBy: {field: CREATED_AT, direction: DESC}) {
              nodes {
                id title body url createdAt mergedAt
                additions deletions changedFiles
                repository { nameWithOwner }
              }
            }
          }
        }
        """
        let result: PullRequestsResponse = try await execute(query: query, variables: ["limit": limit])

        return result.viewer.pullRequests.nodes.compactMap { pr in
            guard let createdAt = parseDate(pr.createdAt) else { return nil }
            return PullRequest(
                id: pr.id, title: pr.title, body: pr.body, url: pr.url,
                createdAt: createdAt, mergedAt: pr.mergedAt.flatMap(parseDate),
                additions: pr.additions, deletions: pr.deletions,
                changedFiles: pr.changedFiles, repositoryName: pr.repository.nameWithOwner
            )
        }
    }

    // MARK: - Issues

    func fetchIssues(limit: Int = 20) async throws -> [Issue] {
        let query = """
        query($limit: Int!) {
          viewer {
            issues(first: $limit, orderBy: {field: CREATED_AT, direction: DESC}) {
              nodes {
                id title body url createdAt closedAt
                repository { nameWithOwner }
              }
            }
          }
        }
        """
        let result: IssuesResponse = try await execute(query: query, variables: ["limit": limit])

        return result.viewer.issues.nodes.compactMap { issue in
            guard let createdAt = parseDate(issue.createdAt) else { return nil }
            return Issue(
                id: issue.id, title: issue.title, body: issue.body, url: issue.url,
                createdAt: createdAt, closedAt: issue.closedAt.flatMap(parseDate),
                repositoryName: issue.repository.nameWithOwner
            )
        }
    }

    // MARK: - Commits

    func fetchCommits(limit: Int = 20) async throws -> [Commit] {
        let query = """
        query {
          viewer {
            login
            repositories(first: 10, orderBy: {field: PUSHED_AT, direction: DESC}) {
              nodes {
                nameWithOwner
                defaultBranchRef {
                  target {
                    ... on Commit {
                      history(first: 10) {
                        nodes {
                          oid message committedDate additions deletions url
                          author { user { login } }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        """
        let result: CommitsResponse = try await execute(query: query)
        let login = result.viewer.login

        let commits = result.viewer.repositories.nodes.flatMap { repo -> [Commit] in
            guard let nodes = repo.defaultBranchRef?.target?.history?.nodes else { return [] }
            return nodes
                .filter { $0.author?.user?.login == login }
                .compactMap { c in
                    guard let date = parseDate(c.committedDate) else { return nil }
                    return Commit(
                        id: c.oid, message: c.message, url: c.url,
                        committedDate: date, additions: c.additions, deletions: c.deletions,
                        repositoryName: repo.nameWithOwner
                    )
                }
        }

        return Array(commits.sorted { $0.committedDate > $1.committedDate }.prefix(limit))
    }

    // MARK: - Networking

    private func execute<T: Decodable>(query: String, variables: [String: Any] = [:]) async throws -> T {
        var request = URLRequest(url: URL(string: "https://api.github.com/graphql")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["query": query, "variables": variables]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw GitHubAPIError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        let wrapper = try JSONDecoder().decode(GraphQLWrapper<T>.self, from: data)
        if let errors = wrapper.errors, !errors.isEmpty {
            throw GitHubAPIError.graphQL(errors.map(\.message))
        }
        guard let result = wrapper.data else {
            throw GitHubAPIError.invalidResponse
        }
        return result
    }

    // MARK: - Date Parsing

    private func parseDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: string) { return date }
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
}

// MARK: - GraphQL Response Wrapper

private struct GraphQLWrapper<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLErrorEntry]?
}

private struct GraphQLErrorEntry: Decodable {
    let message: String
}

// MARK: - Viewer

private struct ViewerResponse: Decodable {
    let viewer: ViewerData

    struct ViewerData: Decodable {
        let login: String
        let name: String?
        let avatarUrl: String
    }
}

// MARK: - Contributions

private struct ContributionsResponse: Decodable {
    let viewer: ViewerContributions

    struct ViewerContributions: Decodable {
        let contributionsCollection: ContributionsCollection
    }

    struct ContributionsCollection: Decodable {
        let contributionCalendar: ContributionCalendar
    }

    struct ContributionCalendar: Decodable {
        let weeks: [ContributionWeek]
    }

    struct ContributionWeek: Decodable {
        let contributionDays: [ContributionDayEntry]
    }

    struct ContributionDayEntry: Decodable {
        let date: String
        let contributionCount: Int
        let contributionLevel: ContributionLevel
    }
}

private enum ContributionLevel: String, Decodable {
    case none = "NONE"
    case firstQuartile = "FIRST_QUARTILE"
    case secondQuartile = "SECOND_QUARTILE"
    case thirdQuartile = "THIRD_QUARTILE"
    case fourthQuartile = "FOURTH_QUARTILE"

    var numericValue: Int {
        switch self {
        case .none: 0
        case .firstQuartile: 1
        case .secondQuartile: 2
        case .thirdQuartile: 3
        case .fourthQuartile: 4
        }
    }
}

// MARK: - Pull Requests

private struct PullRequestsResponse: Decodable {
    let viewer: ViewerPRs

    struct ViewerPRs: Decodable {
        let pullRequests: PRConnection
    }

    struct PRConnection: Decodable {
        let nodes: [PRNode]
    }

    struct PRNode: Decodable {
        let id: String
        let title: String
        let body: String
        let url: String
        let createdAt: String
        let mergedAt: String?
        let additions: Int
        let deletions: Int
        let changedFiles: Int
        let repository: RepositoryInfo
    }
}

// MARK: - Issues

private struct IssuesResponse: Decodable {
    let viewer: ViewerIssues

    struct ViewerIssues: Decodable {
        let issues: IssueConnection
    }

    struct IssueConnection: Decodable {
        let nodes: [IssueNode]
    }

    struct IssueNode: Decodable {
        let id: String
        let title: String
        let body: String
        let url: String
        let createdAt: String
        let closedAt: String?
        let repository: RepositoryInfo
    }
}

// MARK: - Commits

private struct CommitsResponse: Decodable {
    let viewer: ViewerCommits

    struct ViewerCommits: Decodable {
        let login: String
        let repositories: RepoConnection
    }

    struct RepoConnection: Decodable {
        let nodes: [RepoNode]
    }

    struct RepoNode: Decodable {
        let nameWithOwner: String
        let defaultBranchRef: BranchRef?
    }

    struct BranchRef: Decodable {
        let target: CommitTarget?
    }

    struct CommitTarget: Decodable {
        let history: CommitHistory?
    }

    struct CommitHistory: Decodable {
        let nodes: [CommitNode]
    }

    struct CommitNode: Decodable {
        let oid: String
        let message: String
        let committedDate: String
        let additions: Int
        let deletions: Int
        let url: String
        let author: CommitAuthor?
    }

    struct CommitAuthor: Decodable {
        let user: CommitUser?
    }

    struct CommitUser: Decodable {
        let login: String
    }
}

// MARK: - Shared

private struct RepositoryInfo: Decodable {
    let nameWithOwner: String
}
