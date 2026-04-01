import SwiftUI

struct PRDetailView: View {
    let item: RepoDetailItem
    @State private var viewModel = PRDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                divider
                bodySection
                divider
                commitSection
            }
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

    private var divider: some View {
        Rectangle()
            .fill(AppTheme.Colors.border)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(AppTheme.Fonts.pageTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            HStack(spacing: 8) {
                if case .pullRequest(let number, _) = item.type, number > 0 {
                    Text("PR #\(number)")
                        .font(AppTheme.Fonts.badgeSmall)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.primary)
                        .clipShape(Capsule())
                }

                if case .pullRequest(_, let merged) = item.type, merged {
                    Text(StringLiterals.Badge.merged)
                        .font(AppTheme.Fonts.badgeSmall)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: 0xA78BFA))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: 0x1E1B4B))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            HStack(spacing: 12) {
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
            }
            .font(AppTheme.Fonts.stats)
            .foregroundStyle(AppTheme.Colors.textMeta)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Body

    @ViewBuilder
    private var bodySection: some View {
        if !item.body.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                bodyContent
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                translationToggle
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
            }
        }
    }

    @ViewBuilder
    private var bodyContent: some View {
        if LanguageDetector.isLikelyEnglish(item.body) {
            if viewModel.showOriginal {
                bodyText(item.body)
            } else {
                switch viewModel.translatedBody {
                case .loading:
                    ProgressView()
                        .tint(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                case .loaded(let translated):
                    VStack(alignment: .leading, spacing: 12) {
                        bodyText(translated)
                        Text(StringLiterals.PRDetail.translatedByAI)
                            .font(AppTheme.Fonts.caption)
                            .foregroundStyle(AppTheme.Colors.textMeta)
                    }
                case .error:
                    bodyText(item.body)
                }
            }
        } else {
            bodyText(item.body)
        }
    }

    private func bodyText(_ text: String) -> some View {
        MarkdownBodyView(text: text)
    }

    @ViewBuilder
    private var translationToggle: some View {
        if LanguageDetector.isLikelyEnglish(item.body), viewModel.isTranslated {
            Button(action: viewModel.toggleOriginal) {
                HStack(spacing: 5) {
                    Text("🌐")
                        .font(.system(size: 13))
                    Text(viewModel.showOriginal
                        ? StringLiterals.PRDetail.showTranslation
                        : StringLiterals.PRDetail.showOriginal)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Commits

    @ViewBuilder
    private var commitSection: some View {
        if !item.commits.isEmpty {
            PRCommitTimelineView(
                commits: item.commits,
                showAll: viewModel.showAllCommits,
                onToggleShowAll: viewModel.toggleShowAllCommits
            )
            .padding(16)
        }
    }
}
