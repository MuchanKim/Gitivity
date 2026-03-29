import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    titleRow
                    profileHero
                    statsSection
                    contributionGrid
                    activitySection
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
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

    private var profileHero: some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: viewModel.user?.avatarURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(AppTheme.Colors.cardBackground)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 3))

            VStack(spacing: 2) {
                Text(viewModel.user?.name ?? viewModel.user?.login ?? "")
                    .font(AppTheme.Fonts.profileName)
                    .foregroundStyle(.white)
                Text("@\(viewModel.user?.login ?? "")")
                    .font(AppTheme.Fonts.cardBody)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var statsSection: some View {
        ActivityStatsView(
            commits: viewModel.totalCommits,
            prs: viewModel.totalPRs,
            repos: viewModel.activeRepos
        )
    }

    private var contributionGrid: some View {
        ContributionGridView(contributions: viewModel.contributions)
    }

    @ViewBuilder
    private var activitySection: some View {
        if !viewModel.categoryDistribution.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(StringLiterals.Profile.activityClassification)
                    .font(AppTheme.Fonts.sectionTitle)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                ActivityBarView(
                    distribution: viewModel.categoryDistribution,
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
    }
}
