import Foundation

protocol AIProvider: Sendable {
    func summarize(prompt: String) async throws -> String
}
