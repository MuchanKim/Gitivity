import SwiftUI

struct ContributionGridView: View {
    let contributions: [ContributionDay]

    private let rows = 7
    private let gap: CGFloat = 2

    private var weeks: [[ContributionDay?]] {
        let sorted = contributions.sorted { $0.date < $1.date }
        let calendar = Calendar.current

        guard let firstDate = sorted.first?.date else { return [] }
        let firstWeekday = (calendar.component(.weekday, from: firstDate) + 5) % 7 // Mon=0

        var grid: [[ContributionDay?]] = []
        var currentWeek: [ContributionDay?] = Array(repeating: nil, count: firstWeekday)

        for day in sorted {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                grid.append(currentWeek)
                currentWeek = []
            }
        }
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 { currentWeek.append(nil) }
            grid.append(currentWeek)
        }
        return grid
    }

    private var monthLabels: [(offset: Int, label: String)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"

        var labels: [(offset: Int, label: String)] = []
        var lastMonth = -1

        for (weekIndex, week) in weeks.enumerated() {
            guard let firstDay = week.compactMap({ $0 }).first else { continue }
            let month = calendar.component(.month, from: firstDay.date)
            if month != lastMonth {
                labels.append((weekIndex, formatter.string(from: firstDay.date)))
                lastMonth = month
            }
        }
        return labels
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            monthLabelRow
            GeometryReader { geometry in
                let columnCount = CGFloat(max(weeks.count, 1))
                let cellSize = (geometry.size.width - gap * (columnCount - 1)) / columnCount

                HStack(spacing: gap) {
                    ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                        VStack(spacing: gap) {
                            ForEach(0..<rows, id: \.self) { row in
                                if let day = week[row] {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(grassColor(level: day.level))
                                        .frame(height: cellSize)
                                } else {
                                    Color.clear
                                        .frame(height: cellSize)
                                }
                            }
                        }
                    }
                }
            }
            .aspectRatio(CGFloat(max(weeks.count, 1)) / CGFloat(rows), contentMode: .fit)

            legend
        }
        .cardStyle()
    }

    private var monthLabelRow: some View {
        GeometryReader { geometry in
            let columnCount = CGFloat(max(weeks.count, 1))
            let colWidth = (geometry.size.width) / columnCount

            ZStack(alignment: .leading) {
                ForEach(monthLabels, id: \.offset) { item in
                    Text(item.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textMeta)
                        .offset(x: CGFloat(item.offset) * colWidth)
                }
            }
        }
        .frame(height: 12)
    }

    private var legend: some View {
        HStack {
            Spacer()
            HStack(spacing: 3) {
                Text("Less")
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.Colors.textMeta)
                ForEach(0..<5) { level in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(grassColor(level: level))
                        .frame(width: 8, height: 8)
                }
                Text("More")
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.Colors.textMeta)
            }
        }
    }

    private func grassColor(level: Int) -> Color {
        switch level {
        case 0: AppTheme.GrassColors.level0
        case 1: AppTheme.GrassColors.level1
        case 2: AppTheme.GrassColors.level2
        case 3: AppTheme.GrassColors.level3
        default: AppTheme.GrassColors.level4
        }
    }
}
