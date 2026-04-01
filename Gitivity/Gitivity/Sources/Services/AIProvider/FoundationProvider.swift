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
            instructions: """
            당신은 GitHub 활동 분석 도우미입니다. 개발자의 GitHub 활동을 분석하여 기술적으로 어떤 변경이 있었는지 보고서 형식으로 요약합니다.
            규칙:
            - 한국어로 응답합니다.
            - 마크다운 문법(**, *, #, -, ```, 번호 목록)을 절대 사용하지 마세요. 순수 텍스트만 출력합니다.
            - 보고서 톤으로 작성합니다. (예: ~되었습니다, ~추가되었습니다)
            - 기술적으로 무엇이 변경되었는지(What)에 집중합니다.
            - 프롬프트에서 지정한 출력 형식을 정확히 따릅니다.
            """
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
                    break
                }
            }
            throw .generationFailed(underlying: error)
        }
    }
}
