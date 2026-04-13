import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleRow
                    .padding(.horizontal, 20)

                switch viewModel.profileState {
                case .loading:
                    ScrollView {
                        ProfileSkeletonView()
                    }
                case .loaded(let data):
                    ScrollView {
                        VStack(spacing: 12) {
                            profileHeader(data: data)

                            periodHeader
                            streakStars(data: data)
                            contributionChart(data: data)

                            sectionLabel("기여 히스토리")
                            ContributionGridView(contributions: data.contributions)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await viewModel.load(forceRefresh: true)
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
            .background(AmbientBackground())
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
        .padding(.top, 16)
    }

    private func profileHeader(data: ProfileData) -> some View {
        VStack(spacing: 12) {
                AsyncImage(url: URL(string: data.user.avatarURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(AppTheme.Colors.cardBackground)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.Colors.primary, Color(hex: 0x3B82F6), Color(hex: 0xA78BFA)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: AppTheme.Colors.primary.opacity(0.15), radius: 20)
                .shadow(color: Color(hex: 0x3B82F6).opacity(0.08), radius: 40)

                VStack(spacing: 2) {
                    Text(data.user.name ?? data.user.login)
                        .font(AppTheme.Fonts.profileName)
                        .foregroundStyle(AppTheme.Colors.textBright)
                    Text("@\(data.user.login)")
                        .font(AppTheme.Fonts.cardBody)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }

                BadgePillsView(badges: viewModel.badges)
            }
            .padding(.top, 20)
            .padding(.bottom, 12)
    }

    private var periodHeader: some View {
        HStack {
            Text("활동 요약")
                .font(AppTheme.Fonts.sectionLabel)
                .foregroundStyle(AppTheme.Colors.textMeta)
                .tracking(0.8)
            Spacer()
            HStack(spacing: 4) {
                ForEach(ProfilePeriod.allCases) { period in
                    Button {
                        viewModel.selectedPeriod = period
                        Task { await viewModel.load(forceRefresh: false) }
                    } label: {
                        Text(period.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(
                                viewModel.selectedPeriod == period
                                    ? AppTheme.Colors.textBright
                                    : AppTheme.Colors.textMeta
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                viewModel.selectedPeriod == period
                                    ? Color.white.opacity(0.08)
                                    : .clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 4)
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(AppTheme.Fonts.sectionLabel)
                .foregroundStyle(AppTheme.Colors.textMeta)
                .tracking(0.8)
            Spacer()
        }
        .padding(.top, 4)
    }

    private func streakStars(data: ProfileData) -> some View {
        StreakStarsView(
            streak: data.currentStreak,
            bestStreak: data.currentStreak,
            totalStars: data.totalStars,
            topRepoName: data.topRepoName,
            topRepoStars: data.topRepoStars
        )
    }

    private func contributionChart(data: ProfileData) -> some View {
        ContributionChartView(
            totalCommits: data.totalCommits,
            totalPRs: data.totalPRs,
            totalReviews: data.totalReviews,
            totalIssues: data.totalIssues,
            categoryDistribution: viewModel.categoryDistribution
        )
    }
}
