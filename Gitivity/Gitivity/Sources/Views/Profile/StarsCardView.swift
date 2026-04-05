import SwiftUI

struct StarsCardView: View {
    let totalStars: Int
    let topRepoName: String
    let topRepoStars: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.Colors.starGold)
                .frame(width: 36, height: 36)
                .background(AppTheme.Colors.aiCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))

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
        .padding(14)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}
