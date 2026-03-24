import Foundation

struct FoundationProvider: AIProvider {
    func summarize(prompt: String) async throws -> String {
        // TODO: FoundationModels 프레임워크 연동
        return ""
    }
}
