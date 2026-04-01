import SwiftUI

struct ActivityStatsView: View {
    let commits: Int
    let prs: Int
    let repos: Int

    var body: some View {
        HStack(spacing: 5) {
            statBox(value: "\(commits)", label: StringLiterals.Stats.commits, color: AppTheme.Colors.textPrimary)
            statBox(value: "\(prs)", label: StringLiterals.Stats.pr, color: Color(hex: 0x60A5FA))
            statBox(value: "\(repos)", label: StringLiterals.Stats.repos, color: Color(hex: 0xA78BFA))
        }
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.Fonts.statNumber)
                .foregroundStyle(color)
            Text(label)
                .font(AppTheme.Fonts.stats)
                .foregroundStyle(AppTheme.Colors.textTertiary)
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
}
