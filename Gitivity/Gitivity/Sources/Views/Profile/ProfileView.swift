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
                        VStack(spacing: 14) {
                            titleRow
                            profileHeader(data: data)
                            contributionChart(data: data)
                            starsCard(data: data)
                            ContributionGridView(contributions: data.contributions)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(StringLiterals.Profile.title)
                    .font(AppTheme.Fonts.screenTitle)
                    .tracking(-0.5)
                    .foregroundStyle(AppTheme.Colors.textBright)
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

            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.primary, AppTheme.Colors.primaryLight],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 32, height: 2)
        }
        .padding(.top, 14)
    }

    private func profileHeader(data: ProfileData) -> some View {
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

            BadgePillsView(badges: viewModel.badges)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func contributionChart(data: ProfileData) -> some View {
        ContributionChartView(
            totalCommits: data.totalCommits,
            totalPRs: data.totalPRs,
            totalReviews: data.totalReviews,
            totalIssues: data.totalIssues,
            categoryDistribution: {
                if case .loaded(let dist) = viewModel.categoryState { return dist }
                return [:]
            }(),
            streak: data.currentStreak
        )
    }

    private func starsCard(data: ProfileData) -> some View {
        StarsCardView(
            totalStars: data.totalStars,
            topRepoName: data.topRepoName,
            topRepoStars: data.topRepoStars
        )
    }
}
