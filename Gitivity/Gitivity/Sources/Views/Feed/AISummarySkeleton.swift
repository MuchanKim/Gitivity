import SwiftUI

struct AISummarySkeleton: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Text(StringLiterals.AI.summaryLabel)
                    .font(AppTheme.Fonts.label)
                    .foregroundStyle(AppTheme.Colors.aiLabel)
                    .tracking(0.5)
                ProgressView()
                    .controlSize(.mini)
                    .tint(AppTheme.Colors.aiLabel)
            }

            VStack(alignment: .leading, spacing: 6) {
                skeletonLine()
                skeletonLine(width: 200)
                skeletonLine(width: 140)
            }
            .padding(.top, 4)
        }
    }

    private func skeletonLine(width: CGFloat? = nil) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(AppTheme.Colors.textTertiary.opacity(0.15))
            .frame(width: width, height: 10)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .opacity(isAnimating ? 0.4 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}
