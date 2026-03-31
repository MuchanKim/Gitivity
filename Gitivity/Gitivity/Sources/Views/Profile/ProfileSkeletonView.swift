import SwiftUI

struct ProfileSkeletonView: View {
    var body: some View {
        VStack(spacing: 16) {
            titleRow
            avatarSection
            statsSection
            contributionGridSkeleton
            activityClassificationSkeleton
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
    }

    private var titleRow: some View {
        HStack {
            Text(StringLiterals.Profile.title)
                .font(AppTheme.Fonts.screenTitle)
                .foregroundStyle(.white)
            Spacer()
            SkeletonBlock(width: 32, height: 32)
                .clipShape(Circle())
        }
        .padding(.top, 4)
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
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var statsSection: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { _ in
                statBoxSkeleton
            }
        }
    }

    private var statBoxSkeleton: some View {
        VStack(spacing: 4) {
            SkeletonBlock(width: 36, height: 18)
            SkeletonBlock(width: 48, height: 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var contributionGridSkeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SkeletonBlock(width: 80, height: 12)
                Spacer()
                SkeletonBlock(width: 50, height: 10)
            }
            RoundedRectangle(cornerRadius: 4)
                .fill(AppTheme.Colors.textTertiary.opacity(0.08))
                .frame(height: 60)
                .frame(maxWidth: .infinity)
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

    private var activityClassificationSkeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonBlock(width: 90, height: 12)
            RoundedRectangle(cornerRadius: 3)
                .fill(AppTheme.Colors.textTertiary.opacity(0.08))
                .frame(height: 6)
                .frame(maxWidth: .infinity)
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
