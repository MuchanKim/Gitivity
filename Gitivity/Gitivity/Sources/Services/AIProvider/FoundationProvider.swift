import Foundation
import FoundationModels
import os

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

    func summarize(prompt: String) async throws(AIProviderError) -> String {
        let status = availabilityStatus
        AILogger.availability.info("status: \(String(describing: status))")

        guard status == .available else {
            AILogger.availability.warning("model unavailable: \(String(describing: status))")
            throw .modelUnavailable
        }

        let session = LanguageModelSession(
            instructions: "You are a helpful assistant that summarizes GitHub activity. Respond concisely in the same language as the prompt."
        )

        AILogger.generation.debug("prompt length: \(prompt.count) chars")

        do {
            let response = try await session.respond(to: prompt)
            AILogger.generation.info("succeeded, response: \(response.content.count) chars")
            return response.content
        } catch {
            AILogger.generation.error("failed: \(error)")
            if let genError = error as? LanguageModelSession.GenerationError {
                switch genError {
                case .exceededContextWindowSize:
                    throw .contextWindowExceeded
                case .unsupportedLanguageOrLocale:
                    throw .unsupportedLocale
                default:
                    throw .generationFailed(underlying: error)
                }
            }
            throw .generationFailed(underlying: error)
        }
    }
}
