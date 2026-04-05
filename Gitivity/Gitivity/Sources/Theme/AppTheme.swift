import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let background = Color(hex: 0x080E18)
        static let cardBackground = Color(hex: 0x0F1A28)
        static let aiCardBackground = Color(hex: 0x081220)
        static let border = Color(hex: 0x152030)
        static let primary = Color(hex: 0x06B6D4)
        static let primaryLight = Color(hex: 0x22D3EE)
        static let aiLabel = Color(hex: 0x67E8F9)
        static let textBright = Color(hex: 0xF1F5F9)
        static let textPrimary = Color(hex: 0xE2E8F0)
        static let textSecondary = Color(hex: 0x94A3B8)
        static let textTertiary = Color(hex: 0x64748B)
        static let textMeta = Color(hex: 0x475569)
        static let danger = Color(hex: 0xF87171)
        static let additions = Color(hex: 0x34D399)
        static let deletions = Color(hex: 0xF87171)
        static let starGold = Color(hex: 0xFBBF24)

        // Contribution type chart colors
        static let chartPR = Color(hex: 0x34D399)
        static let chartReview = Color(hex: 0xA78BFA)
        static let chartIssue = Color(hex: 0xFB923C)
    }

    // MARK: - Commit Category Colors
    enum CategoryColors {
        static let feat = Color(hex: 0x34D399)
        static let fix = Color(hex: 0xFB923C)
        static let style = Color(hex: 0xA78BFA)
        static let chore = Color(hex: 0x94A3B8)
        static let refactor = Color(hex: 0x60A5FA)
        static let docs = Color(hex: 0xFBBF24)
        static let test = Color(hex: 0xF472B6)
    }

    // MARK: - Contribution Grass Colors
    enum GrassColors {
        static let level0 = Color(hex: 0x131F2E)
        static let level1 = Color(hex: 0x0C2D48)
        static let level2 = Color(hex: 0x1E5F8A)
        static let level3 = Color(hex: 0x3B82F6)
        static let level4 = Color(hex: 0x60A5FA)
    }

    // MARK: - Typography
    enum Fonts {
        // Display
        static let screenTitle = Font.system(size: 28, weight: .black)
        static let pageTitle = Font.system(size: 24, weight: .heavy)

        // Profile
        static let profileName = Font.system(size: 20, weight: .bold)
        static let statNumber = Font.system(size: 26, weight: .bold)

        // Card
        static let cardTitle = Font.system(size: 16, weight: .bold)
        static let cardTitleSemibold = Font.system(size: 16, weight: .semibold)
        static let cardBody = Font.system(size: 14)
        static let cardBodySemibold = Font.system(size: 14, weight: .semibold)

        // Meta
        static let timestamp = Font.system(size: 13)
        static let sectionTitle = Font.system(size: 13, weight: .semibold)
        static let stats = Font.system(size: 12)

        // Small
        static let label = Font.system(size: 11, weight: .bold)
        static let legend = Font.system(size: 11)
        static let caption = Font.system(size: 10)
        static let badgeTitle = Font.system(size: 10, weight: .bold)
        static let badgeSmall = Font.system(size: 9, weight: .bold)

        // Onboarding
        static let onboardingIcon = Font.system(size: 44)
        static let onboardingTitle = Font.system(size: 24, weight: .heavy)
        static let onboardingBody = Font.system(size: 13)
        static let skipButton = Font.system(size: 14)
        static let privacyNotice = Font.system(size: 9)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
