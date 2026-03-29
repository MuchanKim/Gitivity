import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let background = Color(hex: 0x0F1729)
        static let cardBackground = Color(hex: 0x1A2332)
        static let aiCardBackground = Color(hex: 0x111D2E)
        static let border = Color(hex: 0x1E293B)
        static let primary = Color(hex: 0x6366F1)
        static let aiLabel = Color(hex: 0x22D3EE)
        static let textPrimary = Color(hex: 0xE2E8F0)
        static let textSecondary = Color(hex: 0x94A3B8)
        static let textTertiary = Color(hex: 0x64748B)
        static let textMeta = Color(hex: 0x475569)
        static let danger = Color(hex: 0xF87171)
        static let additions = Color(hex: 0x4ADE80)
        static let deletions = Color(hex: 0xF87171)
    }

    // MARK: - Commit Category Colors
    enum CategoryColors {
        static let feat = Color(hex: 0x4ADE80)
        static let fix = Color(hex: 0xF59E0B)
        static let style = Color(hex: 0xA78BFA)
        static let chore = Color(hex: 0x64748B)
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
