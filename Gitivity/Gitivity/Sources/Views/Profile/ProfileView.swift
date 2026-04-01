import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.profileState {
                case .loading:
                    ScrollView {
                        ProfileSkeletonView()
                    }
                case .loaded(let data):
                    ScrollView {
                        VStack(spacing: 16) {
                            titleRow
                            profileHero(data: data)
                            statsSection(data: data)
                            contributionGrid(data: data)
                            activitySection
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await viewModel.load()
                    }
                case .error(let error):
                    ContentUnavailableView {
                        Label(StringLiterals.Feed.errorOccurred, systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        if viewModel.isRetrying {
                            ProgressView()
                                .tint(AppTheme.Colors.primary)
                        } else {
                            Button(StringLiterals.Feed.retry) {
                                Task { await viewModel.load() }
                            }
                        }
                    }
                }
            }
            .background(AppTheme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await viewModel.load()
            }
        }
    }

    private var titleRow: some View {
        HStack {
            Text(StringLiterals.Profile.title)
                .font(AppTheme.Fonts.screenTitle)
                .foregroundStyle(.white)
            Spacer()
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.Colors.cardBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 1))
            }
        }
        .padding(.top, 4)
    }

    private func profileHero(data: ProfileData) -> some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: data.user.avatarURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(AppTheme.Colors.cardBackground)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 3))

            VStack(spacing: 2) {
                Text(data.user.name ?? data.user.login)
                    .font(AppTheme.Fonts.profileName)
                    .foregroundStyle(.white)
                Text("@\(data.user.login)")
                    .font(AppTheme.Fonts.cardBody)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func statsSection(data: ProfileData) -> some View {
        ActivityStatsView(
            commits: data.totalCommits,
            prs: data.totalPRs,
            repos: data.activeRepos
        )
    }

    private func contributionGrid(data: ProfileData) -> some View {
        ContributionGridView(contributions: data.contributions)
    }

    private var activitySection: some View {
        Group {
            switch viewModel.categoryState {
            case .loading:
                EmptyView()
            case .loaded(let distribution):
                if !distribution.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(StringLiterals.Profile.activityClassification)
                            .font(AppTheme.Fonts.sectionTitle)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        ActivityBarView(
                            distribution: distribution,
                            barHeight: 6,
                            showPercentage: true
                        )
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(AppTheme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                }
            case .error:
                EmptyView()
            }
        }
    }
}
