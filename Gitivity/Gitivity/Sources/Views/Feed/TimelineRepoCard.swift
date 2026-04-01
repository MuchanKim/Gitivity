import SwiftUI

struct TimelineRepoCard: View {
    let item: TimelineItem
    let isLast: Bool
    var aiState: LoadingState<String> = .loading
    var categoryState: LoadingState<[CommitCategory: Int]> = .loading

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            timelineDot
            cardContent
        }
        .padding(.bottom, 16)
    }

    private var timelineDot: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(dotBackgroundColor)
                    .frame(width: 18, height: 18)
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)
            }
            if !isLast {
                Rectangle()
                    .fill(AppTheme.Colors.border)
                    .frame(width: 2)
            }
        }
        .frame(width: 18)
        .padding(.trailing, 4)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerRow
            cardBody
        }
    }

    private var headerRow: some View {
        HStack {
            Text(item.shortRepoName)
                .font(AppTheme.Fonts.cardTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Spacer()
            Text(item.lastActivityDate, style: .relative)
                .font(AppTheme.Fonts.timestamp)
                .foregroundStyle(AppTheme.Colors.textMeta)
        }
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            aiSummarySection

            categorySection

            statsRow
        }
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var aiSummarySection: some View {
        Group {
            switch aiState {
            case .loading:
                AISummarySkeleton()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(AppTheme.Colors.aiCardBackground)
            case .loaded(let summary):
                AISummaryCardView(
                    summary: summary,
                    showDisclaimer: false,
                    extraCount: max(0, item.commitCount - 2)
                )
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(AppTheme.Colors.aiCardBackground)
            case .error(let error):
                AIErrorInlineView(error: error)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(AppTheme.Colors.aiCardBackground)
            }
        }
    }

    private var categorySection: some View {
        Group {
            switch categoryState {
            case .loading:
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.Colors.textTertiary.opacity(0.15))
                    .frame(height: 4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
            case .loaded(let distribution):
                if !distribution.isEmpty {
                    ActivityBarView(distribution: distribution)
                        .padding(.top, 10)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                }
            case .error:
                EmptyView()
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            if item.prCount > 0 {
                Text("PR **\(item.prCount)**")
            }
            Text("\(StringLiterals.Stats.commits) **\(item.commitCount)**")
            Spacer()
            HStack(spacing: 4) {
                Text("+\(item.totalAdditions)")
                    .foregroundStyle(AppTheme.Colors.additions)
                Text("-\(item.totalDeletions)")
                    .foregroundStyle(AppTheme.Colors.deletions)
            }
        }
        .font(AppTheme.Fonts.stats)
        .foregroundStyle(AppTheme.Colors.textTertiary)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .overlay(alignment: .top) {
            Rectangle().fill(AppTheme.Colors.border).frame(height: 1)
        }
    }

    private var dotColor: Color {
        let hash = abs(item.repositoryName.hashValue)
        let colors: [Color] = [.indigo, .purple, .cyan, .blue, .orange]
        return colors[hash % colors.count]
    }

    private var dotBackgroundColor: Color {
        dotColor.opacity(0.2)
    }
}
