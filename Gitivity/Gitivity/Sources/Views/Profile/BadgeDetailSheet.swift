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
                .padding(20)
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
            .tracking(0.8)
    }

    private func earnedRow(_ badge: DeveloperBadge) -> some View {
        HStack(spacing: 12) {
            badgeIcon(badge, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(badge.type.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(badge.type.accentColor)
                Text(badge.type.description)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(badge.detail)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(badge.type.accentColor)
                    .monospacedDigit()
                rarityTag(badge.type.rarity)
            }
        }
        .padding(14)
        .background(rarityBackground(badge.type.rarity, accent: badge.type.accentColor))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(rarityBorderGradient(badge.type.rarity, accent: badge.type.accentColor), lineWidth: 1)
        )
        .shadow(color: rarityShadowColor(badge.type.rarity, accent: badge.type.accentColor), radius: rarityShadowRadius(badge.type.rarity))
    }

    private func lockedRow(_ badge: DeveloperBadge) -> some View {
        HStack(spacing: 12) {
            badgeIcon(badge, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(badge.type.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(badge.type.description)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                ProgressView(value: badge.progress)
                    .tint(badge.type.accentColor.opacity(0.6))
                    .padding(.top, 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(badge.detail)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .monospacedDigit()
                rarityTag(badge.type.rarity, dimmed: true)
            }
        }
        .padding(14)
        .background(AppTheme.Colors.aiCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .opacity(0.45)
    }

    // MARK: - Badge Icon

    private func badgeIcon(_ badge: DeveloperBadge, size: CGFloat) -> some View {
        Image(systemName: badge.type.systemImage)
            .font(.system(size: size * 0.65, weight: .bold))
            .foregroundStyle(badge.isEarned ? .white : AppTheme.Colors.textSecondary)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: badge.isEarned ? badge.type.gradient : [Color(hex: 0x475569), Color(hex: 0x334155)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: badge.isEarned ? badge.type.accentColor.opacity(0.25) : .clear, radius: 6)
    }

    // MARK: - Rarity Styling

    @ViewBuilder
    private func rarityTag(_ rarity: BadgeRarity, dimmed: Bool = false) -> some View {
        Text(rarity.rawValue.uppercased())
            .font(.system(size: 8, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(rarityTagColor(rarity))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(rarityTagBackground(rarity))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .opacity(dimmed ? 0.6 : 1.0)
    }

    private func rarityTagColor(_ rarity: BadgeRarity) -> Color {
        switch rarity {
        case .common: AppTheme.Colors.textSecondary
        case .rare: Color(hex: 0x60A5FA)
        case .epic: Color(hex: 0xA78BFA)
        case .legendary: Color(hex: 0xFFD700)
        }
    }

    private func rarityTagBackground(_ rarity: BadgeRarity) -> Color {
        switch rarity {
        case .common: AppTheme.Colors.textSecondary.opacity(0.1)
        case .rare: Color(hex: 0x60A5FA).opacity(0.1)
        case .epic: Color(hex: 0xA78BFA).opacity(0.1)
        case .legendary: Color(hex: 0xFFD700).opacity(0.1)
        }
    }

    private func rarityBackground(_ rarity: BadgeRarity, accent: Color) -> some ShapeStyle {
        switch rarity {
        case .legendary:
            AnyShapeStyle(
                LinearGradient(
                    colors: [Color(hex: 0xFFD700).opacity(0.06), Color(hex: 0xFB923C).opacity(0.03), Color(hex: 0x0A1420).opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .epic:
            AnyShapeStyle(
                LinearGradient(
                    colors: [Color(hex: 0xA78BFA).opacity(0.05), Color(hex: 0x7C3AED).opacity(0.02), Color(hex: 0x0A1420).opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .rare:
            AnyShapeStyle(
                LinearGradient(
                    colors: [Color(hex: 0x60A5FA).opacity(0.03), Color(hex: 0x0A1420).opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .common:
            AnyShapeStyle(AppTheme.Colors.aiCardBackground)
        }
    }

    private func rarityBorderGradient(_ rarity: BadgeRarity, accent: Color) -> LinearGradient {
        switch rarity {
        case .legendary:
            LinearGradient(
                colors: [Color(hex: 0xFFD700).opacity(0.2), Color(hex: 0xFFD700).opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .epic:
            LinearGradient(
                colors: [Color(hex: 0xA78BFA).opacity(0.15), Color(hex: 0xA78BFA).opacity(0.03), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rare:
            LinearGradient(
                colors: [Color(hex: 0x60A5FA).opacity(0.1), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .common:
            LinearGradient(colors: [AppTheme.Colors.border], startPoint: .top, endPoint: .bottom)
        }
    }

    private func rarityShadowColor(_ rarity: BadgeRarity, accent: Color) -> Color {
        switch rarity {
        case .legendary: Color(hex: 0xFFD700).opacity(0.15)
        case .epic: Color(hex: 0xA78BFA).opacity(0.1)
        default: .clear
        }
    }

    private func rarityShadowRadius(_ rarity: BadgeRarity) -> CGFloat {
        switch rarity {
        case .legendary: 12
        case .epic: 8
        default: 0
        }
    }
}
