import SwiftUI

struct ActivityFeedView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("활동")
                        .font(AppTheme.Fonts.screenTitle)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                        .padding(.bottom, 20)

                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(viewModel.timelineItems.enumerated()), id: \.element.id) { index, item in
                            NavigationLink(value: item) {
                                TimelineRepoCard(
                                    item: item,
                                    isLast: index == viewModel.timelineItems.count - 1
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)
                }
            }
            .background(AppTheme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TimelineItem.self) { item in
                RepoDetailView(item: item)
            }
            .overlay {
                if viewModel.isLoading && viewModel.timelineItems.isEmpty {
                    ProgressView()
                        .tint(AppTheme.Colors.primary)
                } else if let error = viewModel.error, viewModel.timelineItems.isEmpty {
                    ContentUnavailableView {
                        Label("오류 발생", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("다시 시도") {
                            Task { await viewModel.loadFeed() }
                        }
                    }
                } else if viewModel.timelineItems.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "활동 없음",
                        systemImage: "tray",
                        description: Text("최근 GitHub 활동이 없습니다.")
                    )
                }
            }
            .refreshable {
                await viewModel.loadFeed()
            }
            .task {
                await viewModel.loadFeed()
            }
        }
    }
}
