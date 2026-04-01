import SwiftUI

struct RepoDetailView: View {
    let item: TimelineItem
    @State private var viewModel = RepoDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                repoHeader

                if viewModel.detailItems.isEmpty {
                    ProgressView()
                        .tint(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.detailItems) { detailItem in
                        switch detailItem.type {
                        case .pullRequest:
                            PRCardView(
                                item: detailItem,
                                aiState: viewModel.itemAISummaries[detailItem.id] ?? .loading
                            )
                        case .commit(let hash):
                            commitCard(detailItem, hash: hash)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(AppTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let url = URL(string: "https://github.com/\(item.repositoryName)") {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
            }
        }
        .task {
            await viewModel.load(from: item)
        }
    }

    private var repoHeader: some View {
        VStack(spacing: 3) {
            Text(item.shortRepoName)
                .font(AppTheme.Fonts.pageTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(item.repositoryName)
                .font(AppTheme.Fonts.timestamp)
                .foregroundStyle(AppTheme.Colors.textMeta)
        }
        .frame(maxWidth: .infinity)
    }

    private func commitCard(_ item: RepoDetailItem, hash: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(StringLiterals.Badge.commit)
                        .font(AppTheme.Fonts.badgeTitle)
                        .foregroundStyle(AppTheme.Colors.additions)
                        .tracking(0.3)
                    Spacer()
                    Text(item.timestamp, style: .relative)
                        .font(AppTheme.Fonts.timestamp)
                        .foregroundStyle(AppTheme.Colors.textMeta)
                }
                Text(item.title)
                    .font(AppTheme.Fonts.cardTitleSemibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            .padding(16)

            // AI description for commit
            switch viewModel.itemAISummaries[item.id] ?? .loading {
            case .loading:
                AISummarySkeleton()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.aiCardBackground.opacity(0.6))
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppTheme.Colors.border.opacity(0.5)).frame(height: 1)
                    }
            case .loaded(let description):
                CommitAIDescriptionView(description: description)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.aiCardBackground.opacity(0.6))
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppTheme.Colors.border.opacity(0.5)).frame(height: 1)
                    }
            case .error(let error):
                AIErrorInlineView(error: error)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.aiCardBackground.opacity(0.6))
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppTheme.Colors.border.opacity(0.5)).frame(height: 1)
                    }
            }
        }
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}
