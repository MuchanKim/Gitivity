import Foundation

enum GitHubAPIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case graphQL([String])

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "잘못된 API 응답입니다."
        case .httpError(let code): "HTTP 오류: \(code)"
        case .graphQL(let messages): "GraphQL 오류: \(messages.joined(separator: ", "))"
        }
    }
}
