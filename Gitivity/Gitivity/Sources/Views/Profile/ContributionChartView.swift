import SwiftUI

struct ContributionChartView: View {
    let totalCommits: Int
    let totalPRs: Int
    let totalReviews: Int
    let totalIssues: Int
    let categoryDistribution: [CommitCategory: Int]
    let streak: Int

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 14) {
            tabPicker
            chartContent
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            tabButton(title: "기여 유형", index: 0)
            tabButton(title: "커밋 분류", index: 1)
        }
        .padding(2)
        .background(AppTheme.Colors.aiCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(selectedTab == index ? AppTheme.Colors.textPrimary : AppTheme.Colors.textMeta)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(selectedTab == index ? AppTheme.Colors.cardBackground : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var chartContent: some View {
        if selectedTab == 0 {
            contributionTypeChart
        } else {
            commitCategoryChart
        }
    }

    private var contributionTypeChart: some View {
        HStack(spacing: 16) {
            donutChart(
                segments: [
                    (Double(totalCommits), AppTheme.Colors.primary),
                    (Double(totalPRs), AppTheme.Colors.chartPR),
                    (Double(totalReviews), AppTheme.Colors.chartReview),
                    (Double(totalIssues), AppTheme.Colors.chartIssue),
                ]
            )
            VStack(alignment: .leading, spacing: 8) {
                legendRow(color: AppTheme.Colors.primary, label: "커밋", value: totalCommits)
                legendRow(color: AppTheme.Colors.chartPR, label: "PR", value: totalPRs)
                legendRow(color: AppTheme.Colors.chartReview, label: "리뷰", value: totalReviews)
                legendRow(color: AppTheme.Colors.chartIssue, label: "이슈", value: totalIssues)
            }
        }
    }

    private var commitCategoryChart: some View {
        let sorted = categoryDistribution.sorted { $0.value > $1.value }
        return HStack(spacing: 16) {
            donutChart(
                segments: sorted.map { (Double($0.value), categoryColor($0.key)) }
            )
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sorted, id: \.key) { key, value in
                    legendRow(color: categoryColor(key), label: key.rawValue, value: value)
                }
            }
        }
    }

    private func donutChart(segments: [(Double, Color)]) -> some View {
        let total = max(segments.reduce(0) { $0 + $1.0 }, 1)
        return ZStack {
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 - 8
                let lineWidth: CGFloat = 14
                var startAngle = Angle.degrees(-90)

                for (value, color) in segments {
                    let sweep = Angle.degrees(value / total * 360)
                    let path = Path { p in
                        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: startAngle + sweep, clockwise: false)
                    }
                    context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                    startAngle += sweep
                }
            }

            VStack(spacing: 0) {
                Text("\(streak)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AppTheme.Colors.primary)
                Text("일 연속")
                    .font(.system(size: 8))
                    .foregroundStyle(AppTheme.Colors.textMeta)
            }
        }
        .frame(width: 100, height: 100)
    }

    private func legendRow(color: Color, label: String, value: Int) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Spacer()
            Text("\(value)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }

    private func categoryColor(_ category: CommitCategory) -> Color {
        switch category {
        case .feat: AppTheme.CategoryColors.feat
        case .fix: AppTheme.CategoryColors.fix
        case .refactor: AppTheme.CategoryColors.refactor
        case .style: AppTheme.CategoryColors.style
        case .chore: AppTheme.CategoryColors.chore
        case .docs: AppTheme.CategoryColors.docs
        case .test: AppTheme.CategoryColors.test
        }
    }
}
