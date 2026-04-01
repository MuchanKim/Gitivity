import Foundation

struct RepositoryMetadata: Sendable {
    let description: String?
    let readmeExcerpt: String?
    let languages: [String]
    let latestRelease: String?
    let starCount: Int
    let forkCount: Int
}
