import SwiftUI

struct RepoDetailView: View {
    let item: TimelineItem
    @State private var viewModel = RepoDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                repoHeader

                aiSummarySection

                // Detail items
                ForEach(viewModel.detailItems) { detailItem in
                    switch detailItem.type {
                    case .pullRequest:
                        PRCardView(item: detailItem)
                    case .commit(let hash):
                        commitCard(detailItem, hash: hash)
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
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppTheme.Colors.primary)
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

    @ViewBuilder
    private var aiSummarySection: some View {
        if let summary = viewModel.repoSummary {
            VStack(alignment: .leading, spacing: 0) {
                AISummaryCardView(summary: summary)
                    .padding(14)

                if !viewModel.categoryDistribution.isEmpty {
                    ActivityBarView(distribution: viewModel.categoryDistribution)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                }
            }
            .background(AppTheme.Colors.aiCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
    }

    private func commitCard(_ item: RepoDetailItem, hash: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("COMMIT")
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

            if let summary = item.aiSummary {
                AISummaryCardView(summary: summary, showDisclaimer: false)
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
