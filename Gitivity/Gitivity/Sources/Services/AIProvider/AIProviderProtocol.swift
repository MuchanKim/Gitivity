import Foundation

protocol AIProvider: Sendable {
    func summarize(prompt: String) async throws(AIProviderError) -> String
    var availabilityStatus: AIAvailabilityStatus { get }
}

enum AIAvailabilityStatus: Sendable, Equatable {
    case available
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case unknown
}

enum AIProviderError: LocalizedError {
    case modelUnavailable
    case contextWindowExceeded
    case unsupportedLocale
    case generationFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "AI 모델을 사용할 수 없습니다."
        case .contextWindowExceeded:
            "입력이 너무 길어 처리할 수 없습니다."
        case .unsupportedLocale:
            "현재 언어는 AI 모델에서 지원되지 않습니다."
        case .generationFailed(let underlying):
            "AI 생성 실패: \(underlying.localizedDescription)"
        }
    }
}
