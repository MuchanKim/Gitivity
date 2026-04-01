import SwiftUI

struct AISummaryCardView: View {
    let summary: String
    let showDisclaimer: Bool
    var maxLines: Int = 2
    var extraCount: Int = 0

    init(summary: String, showDisclaimer: Bool = true, maxLines: Int = 2, extraCount: Int = 0) {
        self.summary = summary
        self.showDisclaimer = showDisclaimer
        self.maxLines = maxLines
        self.extraCount = extraCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(StringLiterals.AI.summaryLabel)
                .font(AppTheme.Fonts.label)
                .foregroundStyle(AppTheme.Colors.aiLabel)
                .tracking(0.5)

            let cleaned = MarkdownStripper.strip(summary)
            let allLines = cleaned.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let lines = Array(allLines.prefix(maxLines))

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    bulletLine(line)
                }
            }

            if extraCount > 0 {
                Text("그 외 \(extraCount)건")
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .padding(.leading, 20)
                    .padding(.top, 2)
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
