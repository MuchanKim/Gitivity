import SwiftUI

struct TimelineRepoCard: View {
    let item: TimelineItem
    let isLast: Bool
    let index: Int
    let totalCount: Int
    var aiState: LoadingState<String> = .loading
    var categoryState: LoadingState<[CommitCategory: Int]> = .loading

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            timelineDot
            cardContent
        }
        .padding(.bottom, 16)
    }

    @State private var glowActive = false

    private var isToday: Bool {
        Calendar.current.isDateInToday(item.lastActivityDate)
    }

    private var timelineDot: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(AppTheme.Colors.primary.opacity(dotOpacity))
                .frame(width: isNewest ? 8 : 6, height: isNewest ? 8 : 6)
                .shadow(
                    color: isToday
                        ? AppTheme.Colors.primary.opacity(glowActive ? 0.8 : 0.4)
                        : .clear,
                    radius: isToday ? (glowActive ? 6 : 3) : 0
                )
                .opacity(isToday ? (glowActive ? 1.0 : 0.7) : 1.0)
                .padding(.top, 5) // cardTitle(16px) baseline 정렬
            if !isLast {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: isNewest
                                ? [AppTheme.Colors.primary.opacity(0.15), AppTheme.Colors.border.opacity(0.4)]
                                : [AppTheme.Colors.border.opacity(0.4), AppTheme.Colors.border.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2)
                    .padding(.top, 4)
            }
            Spacer(minLength: 0)
        }
        .frame(width: 18)
        .padding(.trailing, 4)
        .onAppear {
            if isToday {
                withAnimation(
                    .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
                ) {
                    glowActive = true
                }
            }
        }
        .onDisappear {
            glowActive = false
        }
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
        .background(AppTheme.CardStyle.backgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.CardStyle.borderGradient, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: isNewest ? 8 : 4, y: isNewest ? 4 : 2)
        .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
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
                AISummaryCardView(summary: summary, showDisclaimer: false)
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

    private var dotOpacity: Double {
        guard totalCount > 1 else { return 1.0 }
        return max(0.2, 1.0 - (Double(index) / Double(totalCount - 1)) * 0.8)
    }

    private var isNewest: Bool {
        index == 0
    }
}
