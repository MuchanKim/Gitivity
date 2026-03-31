import Foundation

struct ProfileData {
    let user: GitHubUser
    let contributions: [ContributionDay]
    let totalCommits: Int
    let totalPRs: Int
    let activeRepos: Int
}
