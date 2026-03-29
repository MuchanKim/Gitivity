import SwiftUI

struct TimelineRepoCard: View {
    let item: TimelineItem
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline dot + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(dotBackgroundColor)
                        .frame(width: 16, height: 16)
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
            .frame(width: 16)
            .padding(.trailing, 6)

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack {
                    Text(item.repositoryName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Spacer()
                    Text(item.lastActivityDate, style: .relative)
                        .font(.system(size: 9))
                        .foregroundStyle(AppTheme.Colors.textMeta)
                }

                // Card body
                VStack(alignment: .leading, spacing: 0) {
                    // AI Summary
                    if let summary = item.aiSummary {
                        AISummaryCardView(summary: summary, showDisclaimer: false)
                            .padding(10)
                    }

                    // Activity bar
                    if !item.categoryDistribution.isEmpty {
                        ActivityBarView(distribution: item.categoryDistribution)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 8)
                    }

                    // Stats
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
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .padding(10)
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppTheme.Colors.border).frame(height: 1)
                    }
                }
                .background(AppTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
            }
        }
        .padding(.bottom, 14)
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
