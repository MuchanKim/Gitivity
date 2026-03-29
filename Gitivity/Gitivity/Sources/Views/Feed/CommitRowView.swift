import SwiftUI

struct CommitRowView: View {
    let commit: ClassifiedCommit

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(categoryColor)
                .frame(width: 7, height: 7)

            Text(commit.translatedMessage ?? commit.originalMessage)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .lineLimit(2)

            Spacer()

            HStack(spacing: 4) {
                if commit.additions > 0 {
                    Text("+\(formattedCount(commit.additions))")
                        .foregroundStyle(AppTheme.Colors.additions)
                }
                if commit.deletions > 0 {
                    Text("-\(formattedCount(commit.deletions))")
                        .foregroundStyle(AppTheme.Colors.deletions)
                }
            }
            .font(.system(size: 12))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }

    private var categoryColor: Color {
        switch commit.category {
        case .feat: AppTheme.CategoryColors.feat
        case .fix: AppTheme.CategoryColors.fix
        case .style, .refactor: AppTheme.CategoryColors.style
        default: AppTheme.CategoryColors.chore
        }
    }

    private func formattedCount(_ count: Int) -> String {
        count >= 1000 ? String(format: "%.1fk", Double(count) / 1000) : "\(count)"
    }
}
