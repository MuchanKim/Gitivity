import SwiftUI

struct PRDetailView: View {
    let item: RepoDetailItem
    @State private var viewModel = PRDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                bodySection
                commitSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(AppTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let url = URL(string: item.url) {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
            }
        }
        .task {
            await viewModel.load(item: item)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Text(StringLiterals.Badge.pullRequest)
                        .font(AppTheme.Fonts.badgeTitle)
                        .foregroundStyle(Color(hex: 0xA78BFA))
                        .tracking(0.3)

                    if case .pullRequest(let number, _) = item.type, number > 0 {
                        Text("#\(number)")
                            .font(AppTheme.Fonts.badgeSmall)
                            .foregroundStyle(AppTheme.Colors.textMeta)
                    }

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
            }

            Text(item.title)
                .font(AppTheme.Fonts.pageTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            statsRow
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            Text(item.timestamp, style: .relative)
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
            if item.changedFiles > 0 {
                Text("\(StringLiterals.PRDetail.files) \(item.changedFiles)")
            }
        }
        .font(AppTheme.Fonts.stats)
        .foregroundStyle(AppTheme.Colors.textMeta)
    }

    // MARK: - Body

    @ViewBuilder
    private var bodySection: some View {
        if !item.body.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(StringLiterals.PRDetail.body)
                        .font(AppTheme.Fonts.label)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .tracking(0.5)

                    Spacer()

                    if LanguageDetector.isLikelyEnglish(item.body), viewModel.isTranslated {
                        Button(action: viewModel.toggleOriginal) {
                            Text(viewModel.showOriginal
                                ? StringLiterals.PRDetail.showTranslation
                                : StringLiterals.PRDetail.showOriginal)
                                .font(AppTheme.Fonts.caption)
                                .foregroundStyle(AppTheme.Colors.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                bodyContent
            }
            .padding(16)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var bodyContent: some View {
        if LanguageDetector.isLikelyEnglish(item.body) {
            if viewModel.showOriginal {
                Text(item.body)
                    .font(AppTheme.Fonts.cardBody)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineSpacing(4)
            } else {
                switch viewModel.translatedBody {
                case .loading:
                    ProgressView()
                        .tint(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                case .loaded(let translated):
                    VStack(alignment: .leading, spacing: 4) {
                        Text(translated)
                            .font(AppTheme.Fonts.cardBody)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .lineSpacing(4)
                        Text(StringLiterals.PRDetail.translatedByAI)
                            .font(AppTheme.Fonts.caption)
                            .foregroundStyle(AppTheme.Colors.textMeta)
                            .padding(.top, 2)
                    }
                case .error:
                    Text(item.body)
                        .font(AppTheme.Fonts.cardBody)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineSpacing(4)
                }
            }
        } else {
            Text(item.body)
                .font(AppTheme.Fonts.cardBody)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Commits

    @ViewBuilder
    private var commitSection: some View {
        if !item.commits.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(StringLiterals.PRDetail.commits) (\(item.commits.count))")
                    .font(AppTheme.Fonts.label)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .tracking(0.5)

                PRCommitTimelineView(
                    commits: item.commits,
                    showAll: viewModel.showAllCommits,
                    onToggleShowAll: viewModel.toggleShowAllCommits
                )
            }
            .padding(16)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
    }
}
