import SwiftUI

struct AISummaryCardView: View {
    let summary: String
    let showDisclaimer: Bool

    init(summary: String, showDisclaimer: Bool = true) {
        self.summary = summary
        self.showDisclaimer = showDisclaimer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(StringLiterals.AI.summaryLabel)
                .font(AppTheme.Fonts.label)
                .foregroundStyle(AppTheme.Colors.aiLabel)
                .tracking(0.5)
            Text(summary)
                .font(AppTheme.Fonts.cardBody)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineSpacing(4)
            if showDisclaimer {
                Text(StringLiterals.AI.disclaimer)
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textMeta)
                    .padding(.top, 4)
            }
        }
    }
}
