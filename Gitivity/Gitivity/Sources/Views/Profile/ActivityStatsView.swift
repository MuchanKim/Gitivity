import SwiftUI

struct ActivityStatsView: View {
    let commits: Int
    let prs: Int
    let repos: Int

    var body: some View {
        HStack(spacing: 5) {
            statBox(value: "\(commits)", label: "커밋", color: AppTheme.Colors.textPrimary)
            statBox(value: "\(prs)", label: "PR", color: Color(hex: 0x60A5FA))
            statBox(value: "\(repos)", label: "레포", color: Color(hex: 0xA78BFA))
        }
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}
