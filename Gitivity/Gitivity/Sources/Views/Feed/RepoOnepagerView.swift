import SwiftUI

struct RepoOnepagerView: View {
    let repoName: String
    let metadata: RepositoryMetadata
    let prCount: Int
    let commitCount: Int
    var aiAnalysis: LoadingState<String> = .loading

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            descriptionSection

            if !metadata.languages.isEmpty {
                languageTags
            }

            statsRow

            aiAnalysisSection
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var descriptionSection: some View {
        if let description = metadata.description, !description.isEmpty {
            Text(description)
                .font(AppTheme.Fonts.cardBody)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineSpacing(3)
        }
    }

    private var languageTags: some View {
        FlowLayout(spacing: 6) {
            ForEach(metadata.languages, id: \.self) { language in
                Text(language)
                    .font(AppTheme.Fonts.badgeSmall)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            if let release = metadata.latestRelease {
                statItem(icon: "tag", value: release)
            }
            if prCount > 0 {
                statItem(icon: "arrow.triangle.branch", value: "PR \(prCount)")
            }
            statItem(icon: "point.topleft.filled.down.to.point.bottomright.curvepath", value: "\(commitCount)")
            statItem(icon: "star", value: "\(metadata.starCount)")
            statItem(icon: "tuningfork", value: "\(metadata.forkCount)")
        }
        .font(AppTheme.Fonts.stats)
        .foregroundStyle(AppTheme.Colors.textTertiary)
    }

    private func statItem(icon: String, value: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(value)
        }
    }

    @ViewBuilder
    private var aiAnalysisSection: some View {
        switch aiAnalysis {
        case .loading:
            AISummarySkeleton()
                .padding(.top, 4)
        case .loaded(let analysis):
            VStack(alignment: .leading, spacing: 4) {
                Text(StringLiterals.AI.onepagerLabel)
                    .font(AppTheme.Fonts.label)
                    .foregroundStyle(AppTheme.Colors.aiLabel)
                    .tracking(0.5)

                Text(MarkdownStripper.strip(analysis))
                    .font(AppTheme.Fonts.cardBody)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineSpacing(4)

                Text(StringLiterals.AI.disclaimer)
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textMeta)
                    .padding(.top, 2)
            }
            .padding(.top, 4)
        case .error:
            EmptyView()
        }
    }
}
