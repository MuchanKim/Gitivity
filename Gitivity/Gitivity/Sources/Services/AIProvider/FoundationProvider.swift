import Foundation
import FoundationModels

struct FoundationProvider: AIProvider {
    var availabilityStatus: AIAvailabilityStatus {
        switch SystemLanguageModel.default.availability {
        case .available:
            .available
        case .unavailable(.deviceNotEligible):
            .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            .appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            .modelNotReady
        case .unavailable:
            .unknown
        }
    }

    func summarize(prompt: String) async throws -> String {
        guard availabilityStatus == .available else {
            throw AIProviderError.modelUnavailable
        }

        let session = LanguageModelSession(
            instructions: "You are a helpful assistant that summarizes GitHub activity. Respond concisely in the same language as the prompt."
        )

        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .exceededContextWindowSize:
                throw AIProviderError.contextWindowExceeded
            case .unsupportedLanguageOrLocale:
                throw AIProviderError.unsupportedLocale
            default:
                throw AIProviderError.generationFailed(underlying: error)
            }
        }
    }
}
