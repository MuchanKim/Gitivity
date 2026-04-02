import SwiftUI

struct ActivityFeedView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.feedState {
                case .loading:
                    ScrollView {
                        FeedSkeletonView()
                    }
                case .loaded(let items):
                    if items.isEmpty {
                        ContentUnavailableView(
                            StringLiterals.Feed.noActivity,
                            systemImage: "tray",
                            description: Text(StringLiterals.Feed.noActivityDescription)
                        )
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(StringLiterals.Feed.title)
                                        .font(AppTheme.Fonts.screenTitle)
                                        .tracking(-0.5)
                                        .foregroundStyle(AppTheme.Colors.textBright)

                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.Colors.primary, AppTheme.Colors.primaryLight],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 32, height: 2)
                                }
                                .padding(.horizontal, 18)
                                .padding(.top, 18)
                                .padding(.bottom, 22)

                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                        NavigationLink(value: item) {
                                            TimelineRepoCard(
                                                item: item,
                                                isLast: index == items.count - 1,
                                                index: index,
                                                totalCount: items.count,
                                                aiState: viewModel.aiSummaryStates[item.repoFullName] ?? .loading,
                                                categoryState: viewModel.categoryStates[item.repoFullName] ?? .loading
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 18)
                            }
                        }
                        .refreshable {
                            await viewModel.loadFeed()
                        }
                    }
                case .error(let error):
                    ContentUnavailableView {
                        Label(StringLiterals.Feed.errorOccurred, systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        if viewModel.isRetrying {
                            ProgressView()
                                .tint(AppTheme.Colors.primary)
                        } else {
                            Button(StringLiterals.Feed.retry) {
                                Task { await viewModel.loadFeed() }
                            }
                        }
                    }
                }
            }
            .background(AppTheme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TimelineItem.self) { item in
                RepoDetailView(
                    item: item,
                    feedAISummary: viewModel.aiSummaryStates[item.repoFullName] ?? .loading,
                    feedCategory: viewModel.categoryStates[item.repoFullName] ?? .loading
                )
            }
            .task {
                await viewModel.loadFeed()
            }
        }
    }
}
