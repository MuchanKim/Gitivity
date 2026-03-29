import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Profile hero
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
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            Text("@\(viewModel.user?.login ?? "")")
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                    .padding(.top, 8)

                    // Stats
                    ActivityStatsView(
                        commits: viewModel.totalCommits,
                        prs: viewModel.totalPRs,
                        repos: viewModel.activeRepos
                    )

                    // Contribution grid
                    ContributionGridView(contributions: viewModel.contributions)

                    // Activity bar
                    if !viewModel.categoryDistribution.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("활동 분류")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            ActivityBarView(distribution: viewModel.categoryDistribution)
                        }
                        .padding(12)
                        .background(AppTheme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("프로필")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }
}
