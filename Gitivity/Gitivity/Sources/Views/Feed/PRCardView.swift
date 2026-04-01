import SwiftUI

struct PRCardView: View {
    let item: RepoDetailItem
    var aiState: LoadingState<String> = .loading

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            // AI Summary — switch on aiState instead of item.aiSummary
            switch aiState {
            case .loading:
                AISummarySkeleton()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.aiCardBackground.opacity(0.6))
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppTheme.Colors.border.opacity(0.5)).frame(height: 1)
                    }
            case .loaded(let summary):
                AISummaryCardView(
                    summary: summary,
                    showDisclaimer: false,
                    extraCount: max(0, item.commits.count - 2)
                )
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

            // Commits
            ForEach(item.commits) { commit in
                CommitRowView(commit: commit)
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppTheme.Colors.border.opacity(0.3)).frame(height: 1)
                    }
            }

            statsSection
        }
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                HStack(spacing: 4) {
                    Text(StringLiterals.Badge.pullRequest)
                        .font(AppTheme.Fonts.badgeTitle)
                        .foregroundStyle(Color(hex: 0xA78BFA))
                        .tracking(0.3)
                    if case .pullRequest(_, let merged) = item.type, merged {
                        Text(StringLiterals.Badge.merged)
                            .font(AppTheme.Fonts.badgeSmall)
                            .foregroundStyle(Color(hex: 0xA78BFA))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: 0x1E1B4B))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                Spacer()
                Text(item.timestamp, style: .relative)
                    .font(AppTheme.Fonts.timestamp)
                    .foregroundStyle(AppTheme.Colors.textMeta)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
            Text(item.title)
                .font(AppTheme.Fonts.cardTitleSemibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
        .padding(16)
    }

    private var statsSection: some View {
        HStack(spacing: 10) {
            if item.additions > 0 {
                Text("+\(item.additions)")
                    .foregroundStyle(AppTheme.Colors.additions)
                    .bold()
            }
            if item.deletions > 0 {
                Text("-\(item.deletions)")
                    .foregroundStyle(AppTheme.Colors.deletions)
                    .bold()
            }
            if !item.commits.isEmpty {
                Text("\(StringLiterals.Stats.commits) \(item.commits.count)")
            }
        }
        .font(AppTheme.Fonts.stats)
        .foregroundStyle(AppTheme.Colors.textMeta)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) {
            Rectangle().fill(AppTheme.Colors.border).frame(height: 1)
        }
    }
}
