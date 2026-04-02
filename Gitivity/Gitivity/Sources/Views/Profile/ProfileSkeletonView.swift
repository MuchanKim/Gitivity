import SwiftUI

struct ProfileSkeletonView: View {
    var body: some View {
        VStack(spacing: 14) {
            titleRow
            avatarSection
            donutChartSkeleton
            starsCardSkeleton
            contributionGridSkeleton
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
    }

    private var titleRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(StringLiterals.Profile.title)
                    .font(AppTheme.Fonts.screenTitle)
                    .tracking(-0.5)
                    .foregroundStyle(AppTheme.Colors.textBright)
                Spacer()
                SkeletonBlock(width: 32, height: 32)
                    .clipShape(Circle())
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

    private var avatarSection: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(AppTheme.Colors.cardBackground)
                .frame(width: 80, height: 80)
                .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 3))

            VStack(spacing: 6) {
                SkeletonBlock(width: 100, height: 16)
                SkeletonBlock(width: 72, height: 12)
            }

            // Badge pills skeleton
            HStack(spacing: 6) {
                SkeletonBlock(width: 80, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                SkeletonBlock(width: 80, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var donutChartSkeleton: some View {
        VStack(spacing: 14) {
            // Tab picker skeleton
            HStack(spacing: 0) {
                SkeletonBlock(height: 30)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Chart + legend
            HStack(spacing: 16) {
                // Donut ring skeleton
                Circle()
                    .stroke(AppTheme.Colors.border, lineWidth: 14)
                    .frame(width: 100, height: 100)

                // Legend skeleton
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: 8) {
                            SkeletonBlock(width: 8, height: 8)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                            SkeletonBlock(width: 30, height: 10)
                            Spacer()
                            SkeletonBlock(width: 24, height: 12)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var starsCardSkeleton: some View {
        HStack(spacing: 12) {
            SkeletonBlock(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                SkeletonBlock(width: 40, height: 8)
                SkeletonBlock(width: 28, height: 14)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                SkeletonBlock(width: 80, height: 10)
                SkeletonBlock(width: 30, height: 10)
            }
        }
        .padding(14)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var contributionGridSkeleton: some View {
        VStack(spacing: 6) {
            // Grid placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(AppTheme.Colors.textTertiary.opacity(0.06))
                .aspectRatio(13.0 / 7.0, contentMode: .fit)
                .frame(maxWidth: .infinity)

            // Legend skeleton
            HStack {
                Spacer()
                SkeletonBlock(width: 100, height: 8)
            }
        }
        .padding(14)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}
