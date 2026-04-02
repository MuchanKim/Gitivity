import SwiftUI

struct ContributionGridView: View {
    let contributions: [ContributionDay]

    private let rows = 7
    private let gap: CGFloat = 3

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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
        .padding(14)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
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
        case 0: Color(hex: 0x131F2E)
        case 1: Color(hex: 0x0C2D48)
        case 2: Color(hex: 0x1E5F8A)
        case 3: Color(hex: 0x3B82F6)
        default: Color(hex: 0x60A5FA)
        }
    }
}
