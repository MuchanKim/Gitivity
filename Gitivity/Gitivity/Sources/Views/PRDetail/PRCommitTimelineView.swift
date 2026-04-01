import SwiftUI

struct PRCommitTimelineView: View {
    let commits: [ClassifiedCommit]
    let showAll: Bool
    let onToggleShowAll: () -> Void

    private let initialDisplayCount = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let displayedCommits = showAll ? commits : Array(commits.prefix(initialDisplayCount))

            ForEach(Array(displayedCommits.enumerated()), id: \.element.id) { index, commit in
                commitRow(commit, isLast: index == displayedCommits.count - 1 && (showAll || commits.count <= initialDisplayCount))
            }

            if commits.count > initialDisplayCount {
                expandButton
            }
        }
    }

    private func commitRow(_ commit: ClassifiedCommit, isLast: Bool) -> some View {
        TimelineCommitRow(commit: commit, isLast: isLast)
    }

    private var expandButton: some View {
        Button(action: onToggleShowAll) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.Colors.border)
                        .frame(width: 2, height: 16)
                    Circle()
                        .fill(AppTheme.Colors.textTertiary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .frame(width: 18)
                .padding(.trailing, 8)

                Text(showAll
                    ? StringLiterals.PRDetail.collapseCommits
                    : "\(StringLiterals.PRDetail.showRemainingCommits)\(commits.count - initialDisplayCount)\(StringLiterals.PRDetail.countSuffix)")
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

private struct TimelineCommitRow: View {
    let commit: ClassifiedCommit
    let isLast: Bool
    @State private var isExpanded = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(categoryColor)
                        .frame(width: 8, height: 8)
                }
                if !isLast {
                    Rectangle()
                        .fill(AppTheme.Colors.border)
                        .frame(width: 2)
                }
            }
            .frame(width: 18)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(commit.commitTitle)
                            .font(AppTheme.Fonts.cardBody)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .lineLimit(isExpanded ? nil : 2)

                        HStack(spacing: 6) {
                            Text(String(commit.id.prefix(7)))
                                .font(AppTheme.Fonts.monoCaption)
                                .foregroundStyle(AppTheme.Colors.textMeta)

                            if commit.additions > 0 {
                                Text("+\(commit.additions)")
                                    .foregroundStyle(AppTheme.Colors.additions)
                            }
                            if commit.deletions > 0 {
                                Text("-\(commit.deletions)")
                                    .foregroundStyle(AppTheme.Colors.deletions)
                            }
                        }
                        .font(AppTheme.Fonts.stats)
                    }

                    Spacer()

                    if commit.commitBody != nil {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }

                if isExpanded, let body = commit.commitBody {
                    Text(body)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineSpacing(4)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.Colors.aiCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                if commit.commitBody != nil {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
            }
        }
    }

    private var categoryColor: Color {
        switch commit.category {
        case .feat: AppTheme.CategoryColors.feat
        case .fix: AppTheme.CategoryColors.fix
        case .style, .refactor: AppTheme.CategoryColors.style
        default: AppTheme.CategoryColors.chore
        }
    }
}
