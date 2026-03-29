import SwiftUI

struct ActivityBarView: View {
    let distribution: [CommitCategory: Int]

    var body: some View {
        let total = distribution.values.reduce(0, +)
        if total > 0 {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(sortedCategories, id: \.0) { category, count in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color(for: category))
                            .frame(height: 4)
                            .frame(maxWidth: CGFloat(count) / CGFloat(total) * 200)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(sortedCategories, id: \.0) { category, _ in
                        HStack(spacing: 3) {
                            Circle()
                                .fill(color(for: category))
                                .frame(width: 5, height: 5)
                            Text(category.rawValue)
                                .font(.system(size: 8))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                }
            }
        }
    }

    private var sortedCategories: [(CommitCategory, Int)] {
        distribution.sorted { $0.value > $1.value }
    }

    private func color(for category: CommitCategory) -> Color {
        switch category {
        case .feat: AppTheme.CategoryColors.feat
        case .fix: AppTheme.CategoryColors.fix
        case .style, .refactor: AppTheme.CategoryColors.style
        default: AppTheme.CategoryColors.chore
        }
    }
}
