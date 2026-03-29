import SwiftUI

struct ContributionGridView: View {
    let contributions: [ContributionDay]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("기여 활동")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Spacer()
                Text("최근 30일")
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.Colors.textMeta)
            }

            let rows = stride(from: 0, to: contributions.count, by: 10).map {
                Array(contributions[$0..<min($0 + 10, contributions.count)])
            }

            VStack(spacing: 2) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 2) {
                        ForEach(row) { day in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(grassColor(level: day.level))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private func grassColor(level: Int) -> Color {
        switch level {
        case 0: AppTheme.Colors.cardBackground
        case 1: Color(hex: 0x0E4429)
        case 2: Color(hex: 0x006D32)
        case 3: Color(hex: 0x26A641)
        default: Color(hex: 0x39D353)
        }
    }
}
