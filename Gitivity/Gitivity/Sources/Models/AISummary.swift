import Foundation

struct AISummary: Sendable, Identifiable {
    let id = UUID()
    let content: String
    let generatedAt: Date
    let period: SummaryPeriod
}

enum SummaryPeriod: String, Sendable, CaseIterable {
    case daily = "일간"
    case weekly = "주간"
    case monthly = "월간"
}
