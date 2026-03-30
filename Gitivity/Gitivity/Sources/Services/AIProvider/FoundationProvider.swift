import Foundation
import FoundationModels
import os

private let aiLogger = Logger(subsystem: "com.gitivity", category: "FoundationModels")

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
        let status = availabilityStatus
        aiLogger.info("📡 availability: \(String(describing: status))")

        guard status == .available else {
            aiLogger.error("❌ model unavailable: \(String(describing: status))")
            throw AIProviderError.modelUnavailable
        }

        let session = LanguageModelSession(
            instructions: "You are a helpful assistant that summarizes GitHub activity. Respond concisely in the same language as the prompt."
        )

        let promptLength = prompt.count
        aiLogger.info("📝 prompt length: \(promptLength) chars (≈\(promptLength) tokens for CJK)")

        do {
            let response = try await session.respond(to: prompt)
            aiLogger.info("✅ generation succeeded, response length: \(response.content.count)")
            return response.content
        } catch {
            aiLogger.error("❌ generation failed: \(error)")
            if let genError = error as? LanguageModelSession.GenerationError {
                switch genError {
                case .exceededContextWindowSize:
                    throw AIProviderError.contextWindowExceeded
                case .unsupportedLanguageOrLocale:
                    throw AIProviderError.unsupportedLocale
                default:
                    throw AIProviderError.generationFailed(underlying: error)
                }
            }
            throw AIProviderError.generationFailed(underlying: error)
        }
    }
}
