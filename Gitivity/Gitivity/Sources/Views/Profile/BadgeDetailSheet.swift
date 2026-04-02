import SwiftUI

struct BadgeDetailSheet: View {
    let badges: [DeveloperBadge]

    private var earned: [DeveloperBadge] { badges.filter(\.isEarned) }
    private var inProgress: [DeveloperBadge] { badges.filter { !$0.isEarned } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if !earned.isEmpty {
                        sectionHeader("획득한 뱃지", color: AppTheme.Colors.primary)
                        ForEach(earned) { badge in
                            earnedRow(badge)
                        }
                    }
                    if !inProgress.isEmpty {
                        sectionHeader("도전 중", color: AppTheme.Colors.textMeta)
                        ForEach(inProgress) { badge in
                            lockedRow(badge)
                        }
                    }
                }
                .padding(18)
            }
            .background(AppTheme.Colors.cardBackground)
            .navigationTitle("개발자 뱃지")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }

    private func sectionHeader(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .tracking(0.5)
    }

    private func earnedRow(_ badge: DeveloperBadge) -> some View {
        HStack(spacing: 12) {
            badgeIcon(badge, size: 40, cornerRadius: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.type.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(badge.type.description)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(AppTheme.Colors.aiCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(badge.type.accentColor.opacity(0.1), lineWidth: 1)
        )
    }

    private func lockedRow(_ badge: DeveloperBadge) -> some View {
        HStack(spacing: 12) {
            badgeIcon(badge, size: 40, cornerRadius: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.type.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(badge.type.description)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                ProgressView(value: badge.progress)
                    .tint(AppTheme.Colors.textMeta)
                    .padding(.top, 4)
                Text("\(badge.detail) 달성")
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.Colors.textMeta)
            }
            Spacer()
        }
        .padding(14)
        .background(AppTheme.Colors.aiCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .opacity(0.5)
    }

    private func badgeIcon(_ badge: DeveloperBadge, size: CGFloat, cornerRadius: CGFloat) -> some View {
        Image(systemName: badge.type.systemImage)
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundStyle(badge.isEarned ? .white : AppTheme.Colors.textSecondary)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: badge.isEarned ? badge.type.gradient : [Color(hex: 0x475569), Color(hex: 0x334155)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: badge.isEarned ? badge.type.accentColor.opacity(0.2) : .clear, radius: 4)
    }
}
