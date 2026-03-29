import SwiftUI

struct TimelineRepoCard: View {
    let item: TimelineItem
    let isLast: Bool

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
            if let summary = item.aiSummary {
                AISummaryCardView(summary: summary, showDisclaimer: false)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(AppTheme.Colors.aiCardBackground)
            }

            if !item.categoryDistribution.isEmpty {
                ActivityBarView(distribution: item.categoryDistribution)
                    .padding(.top, item.aiSummary != nil ? 10 : 0)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
            }

            statsRow
        }
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            if item.prCount > 0 {
                Text("PR **\(item.prCount)**")
            }
            Text("커밋 **\(item.commitCount)**")
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
