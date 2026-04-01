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

            let cleaned = MarkdownStripper.strip(summary)
            let lines = cleaned.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    bulletLine(line)
                }
            }

            if showDisclaimer {
                Text(StringLiterals.AI.disclaimer)
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textMeta)
                    .padding(.top, 4)
            }
        }
    }

    private func bulletLine(_ line: String) -> some View {
        let text = line.hasPrefix("· ") ? String(line.dropFirst(2)) : line
        return HStack(alignment: .top, spacing: 6) {
            Text("·")
                .font(AppTheme.Fonts.cardBody)
                .foregroundStyle(AppTheme.Colors.textTertiary)
            Text(text)
                .font(AppTheme.Fonts.cardBody)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineSpacing(4)
        }
    }
}
