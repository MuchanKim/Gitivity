import SwiftUI

struct CommitAIDescriptionView: View {
    let description: String

    var body: some View {
        Text(MarkdownStripper.strip(description))
            .font(AppTheme.Fonts.cardBody)
            .foregroundStyle(AppTheme.Colors.textTertiary)
            .lineSpacing(3)
    }
}
