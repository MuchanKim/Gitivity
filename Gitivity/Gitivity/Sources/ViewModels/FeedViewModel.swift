import Foundation

@Observable
final class FeedViewModel {
    private(set) var feedItems: [FeedItem] = []
    private(set) var isLoading = false

    func loadFeed() async {
        isLoading = true
        defer { isLoading = false }
        // TODO: GitHub API에서 데이터 수집 → 피드 그룹핑
    }
}
