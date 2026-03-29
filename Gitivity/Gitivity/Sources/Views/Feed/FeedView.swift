import SwiftUI

struct FeedView: View {
    @State private var viewModel = FeedViewModel()
    @State private var selectedItem: FeedItem?

    var body: some View {
        NavigationSplitView {
            Group {
                if viewModel.isLoading && viewModel.feedItems.isEmpty {
                    ProgressView("로딩 중...")
                } else if let error = viewModel.error, viewModel.feedItems.isEmpty {
                    ContentUnavailableView {
                        Label("오류 발생", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("다시 시도") {
                            Task { await viewModel.loadFeed() }
                        }
                    }
                } else if viewModel.feedItems.isEmpty {
                    ContentUnavailableView(
                        "활동 없음",
                        systemImage: "tray",
                        description: Text("최근 GitHub 활동이 없습니다.")
                    )
                } else {
                    List(viewModel.feedItems, selection: $selectedItem) { item in
                        FeedItemRow(item: item)
                            .tag(item)
                    }
                    .refreshable {
                        await viewModel.loadFeed()
                    }
                }
            }
            .navigationTitle("피드")
        } detail: {
            if let selectedItem {
                FeedDetailView(item: selectedItem)
            } else {
                ContentUnavailableView(
                    "항목을 선택하세요",
                    systemImage: "text.document",
                    description: Text("왼쪽에서 피드 항목을 선택하면 상세 정보가 표시됩니다.")
                )
            }
        }
        .task {
            await viewModel.loadFeed()
        }
    }
}
