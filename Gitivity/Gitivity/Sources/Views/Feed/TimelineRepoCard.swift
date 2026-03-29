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

    // MARK: - Timeline Dot + Line

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

    // MARK: - Card Content

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerRow
            cardBody
        }
    }

    private var headerRow: some View {
        HStack {
            Text(repoShortName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Spacer()
            Text(item.lastActivityDate, style: .relative)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.Colors.textMeta)
        }
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let summary = item.aiSummary {
                AISummaryCardView(summary: summary, showDisclaimer: false)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.aiCardBackground)
            }

            if !item.categoryDistribution.isEmpty {
                ActivityBarView(distribution: item.categoryDistribution)
                    .padding(.top, item.aiSummary == nil ? 12 : 8)
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
        .font(.system(size: 12))
        .foregroundStyle(AppTheme.Colors.textTertiary)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .overlay(alignment: .top) {
            Rectangle().fill(AppTheme.Colors.border).frame(height: 1)
        }
    }

    // MARK: - Helpers

    private var repoShortName: String {
        item.repositoryName.components(separatedBy: "/").last ?? item.repositoryName
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
