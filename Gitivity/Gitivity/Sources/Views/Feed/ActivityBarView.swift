import SwiftUI

struct ActivityBarView: View {
    let distribution: [CommitCategory: Int]
    var barHeight: CGFloat = 4
    var showPercentage: Bool = false

    private var total: Int { distribution.values.reduce(0, +) }

    var body: some View {
        if total > 0 {
            VStack(alignment: .leading, spacing: showPercentage ? 6 : 3) {
                barSegments
                legend
            }
        }
    }

    private var barSegments: some View {
        Canvas { context, size in
            let cgTotal = CGFloat(total)
            let spacing: CGFloat = 2
            let segmentCount = CGFloat(sortedCategories.count)
            let totalSpacing = spacing * max(segmentCount - 1, 0)
            let availableWidth = size.width - totalSpacing
            var x: CGFloat = 0
            let radius = barHeight / 2

            for (category, count) in sortedCategories {
                let width = availableWidth * CGFloat(count) / cgTotal
                let rect = CGRect(x: x, y: 0, width: width, height: barHeight)
                let path = RoundedRectangle(cornerRadius: radius).path(in: rect)
                context.fill(path, with: .color(color(for: category)))
                x += width + spacing
            }
        }
        .frame(height: barHeight)
    }

    private var legend: some View {
        HStack(spacing: showPercentage ? 10 : 6) {
            ForEach(sortedCategories, id: \.0) { category, count in
                HStack(spacing: 3) {
                    Circle()
                        .fill(color(for: category))
                        .frame(width: 6, height: 6)
                    Text(legendText(for: category, count: count))
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
        }
    }

    private func legendText(for category: CommitCategory, count: Int) -> String {
        if showPercentage {
            let pct = Int(round(Double(count) / Double(total) * 100))
            return "\(category.rawValue) \(pct)%"
        }
        return category.rawValue
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
