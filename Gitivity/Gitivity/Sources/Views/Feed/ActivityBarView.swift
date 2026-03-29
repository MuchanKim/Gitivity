import SwiftUI

struct ActivityBarView: View {
    let distribution: [CommitCategory: Int]
    var barHeight: CGFloat = 4
    var showPercentage: Bool = false

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
            var xOffset: CGFloat = 0
            let radius = barHeight / 2

            for (index, pair) in sortedCategories.enumerated() {
                let (category, count) = pair
                let segmentWidth = CGFloat(count) / CGFloat(total) * size.width
                let rect = CGRect(x: xOffset, y: 0, width: segmentWidth, height: barHeight)

                let isFirst = index == 0
                let isLast = index == sortedCategories.count - 1

                var path: Path
                if isFirst && isLast {
                    path = Path(roundedRect: rect, cornerRadius: radius)
                } else if isFirst {
                    path = Path(roundedRect: rect, cornerRadii: RectangleCornerRadii(
                        topLeading: radius, bottomLeading: radius,
                        bottomTrailing: 0, topTrailing: 0
                    ))
                } else if isLast {
                    path = Path(roundedRect: rect, cornerRadii: RectangleCornerRadii(
                        topLeading: 0, bottomLeading: 0,
                        bottomTrailing: radius, topTrailing: radius
                    ))
                } else {
                    path = Path(rect)
                }

                context.fill(path, with: .color(color(for: category)))
                xOffset += segmentWidth
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
                    if showPercentage {
                        let pct = Int(round(Double(count) / Double(total) * 100))
                        Text("\(category.rawValue) \(pct)%")
                            .font(AppTheme.Fonts.legend)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    } else {
                        Text(category.rawValue)
                            .font(AppTheme.Fonts.legend)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
            }
        }
    }

    private var total: Int {
        distribution.values.reduce(0, +)
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
