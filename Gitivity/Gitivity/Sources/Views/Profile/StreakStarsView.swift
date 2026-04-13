import SwiftUI

struct StreakStarsView: View {
    let streak: Int
    let bestStreak: Int
    let totalStars: Int
    let topRepoName: String
    let topRepoStars: Int

    var body: some View {
        HStack(spacing: 10) {
            streakCard
            starsCard
        }
    }

    private var streakTier: (name: String, color: Color, background: Color)? {
        if streak >= 30 {
            return ("Gold", AppTheme.TierColors.gold, AppTheme.TierColors.gold.opacity(0.15))
        } else if streak >= 14 {
            return ("Silver", AppTheme.TierColors.silver, AppTheme.TierColors.silver.opacity(0.15))
        } else if streak >= 7 {
            return ("Bronze", AppTheme.TierColors.bronze, AppTheme.TierColors.bronze.opacity(0.15))
        }
        return nil
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("STREAK")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textMeta)
                .tracking(0.5)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(streak)")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFB923C), Color(hex: 0xEF4444)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("일")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .padding(.top, 6)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 4) {
                Text("최고 \(bestStreak)일")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.Colors.textTertiary)

                if let tier = streakTier {
                    Text(tier.name)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(tier.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(tier.background)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var starsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("STARS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textMeta)
                .tracking(0.5)

            Text("\(totalStars)")
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xFBBF24), Color(hex: 0xF59E0B)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 6)

            Spacer(minLength: 0)

            if !topRepoName.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(topRepoName)
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                        Text("\(topRepoStars)")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.Colors.starGold)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
