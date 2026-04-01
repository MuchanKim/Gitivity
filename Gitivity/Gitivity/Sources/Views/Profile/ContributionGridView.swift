import SwiftUI

struct ContributionGridView: View {
    let contributions: [ContributionDay]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            gridContent
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            Text(StringLiterals.Profile.contributionActivity)
                .font(AppTheme.Fonts.sectionTitle)
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Spacer()
            Text(StringLiterals.Profile.last30Days)
                .font(AppTheme.Fonts.stats)
                .foregroundStyle(AppTheme.Colors.textMeta)
        }
    }

    private var gridContent: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 10, maximum: 10), spacing: 3)],
            spacing: 3
        ) {
            ForEach(contributions) { day in
                RoundedRectangle(cornerRadius: 2)
                    .fill(grassColor(level: day.level))
                    .frame(width: 10, height: 10)
                    .overlay {
                        if day.level == 0 {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(AppTheme.Colors.border, lineWidth: 0.5)
                        }
                    }
            }
        }
    }

    private func grassColor(level: Int) -> Color {
        switch level {
        case 0: AppTheme.Colors.cardBackground
        case 1: Color(hex: 0x0E4429)
        case 2: Color(hex: 0x006D32)
        case 3: Color(hex: 0x26A641)
        default: Color(hex: 0x39D353)
        }
    }
}
