import Foundation
import FoundationModels

struct FoundationProvider: AIProvider {
    func summarize(prompt: String) async throws -> String {
        guard SystemLanguageModel.default.availability == .available else {
            throw AIProviderError.modelUnavailable
        }
        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)
        return response.content
    }
}

enum AIProviderError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        switch self {
        case .modelUnavailable: "AI 모델을 사용할 수 없습니다."
        }
    }
}
