import SwiftUI

struct BadgePillsView: View {
    let badges: [DeveloperBadge]
    @State private var showSheet = false

    private var earnedBadges: [DeveloperBadge] {
        badges.filter(\.isEarned)
    }

    private var displayBadges: [DeveloperBadge] {
        Array(earnedBadges.prefix(3))
    }

    private var moreCount: Int {
        max(earnedBadges.count - 3, 0)
    }

    var body: some View {
        if !earnedBadges.isEmpty {
            HStack(spacing: 6) {
                ForEach(displayBadges) { badge in
                    badgePill(badge)
                }
                if moreCount > 0 {
                    morePill
                }
            }
            .onTapGesture { showSheet = true }
            .sheet(isPresented: $showSheet) {
                BadgeDetailSheet(badges: badges)
            }
        }
    }

    private func badgePill(_ badge: DeveloperBadge) -> some View {
        HStack(spacing: 6) {
            Image(systemName: badge.type.systemImage)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(
                    LinearGradient(colors: badge.type.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))

            Text(badge.type.name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(badge.type.accentColor)
        }
        .padding(.vertical, 6)
        .padding(.leading, 7)
        .padding(.trailing, 12)
        .background(badge.type.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(badge.type.accentColor.opacity(0.15), lineWidth: 1)
        )
    }

    private var morePill: some View {
        Text("+\(moreCount)")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.textTertiary)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(AppTheme.Colors.textTertiary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(AppTheme.Colors.textTertiary.opacity(0.15), lineWidth: 1)
            )
    }
}
