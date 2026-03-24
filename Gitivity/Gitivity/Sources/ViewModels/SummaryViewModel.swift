import Foundation

@Observable
final class SummaryViewModel {
    private(set) var contributions: [ContributionDay] = []
    private(set) var summary: AISummary?
    private(set) var isLoading = false
    var selectedPeriod: SummaryPeriod = .weekly

    func loadSummary() async {
        isLoading = true
        defer { isLoading = false }
        // TODO: 컨트리뷰션 데이터 + AI 요약 로드
    }
}
