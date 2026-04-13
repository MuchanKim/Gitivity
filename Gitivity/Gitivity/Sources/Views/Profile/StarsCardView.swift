import SwiftUI

struct StarsCardView: View {
    let totalStars: Int
    let topRepoName: String
    let topRepoStars: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.Colors.starGold)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.starGold.opacity(0.12), AppTheme.Colors.starGold.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.Colors.starGold.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: AppTheme.Colors.starGold.opacity(0.06), radius: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text("총 스타")
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                Text("\(totalStars)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }

            Spacer()

            if !topRepoName.isEmpty {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(topRepoName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                        Text("\(topRepoStars)")
                    }
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.Colors.starGold)
                }
            }
        }
        .cardStyle()
    }
}
