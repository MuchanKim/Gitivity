import SwiftUI

struct FeedSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(StringLiterals.Feed.title)
                .font(AppTheme.Fonts.screenTitle)
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    skeletonCard(isLast: index == 2)
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private func skeletonCard(isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline dot skeleton
            VStack(spacing: 0) {
                Circle()
                    .fill(AppTheme.Colors.textTertiary.opacity(0.15))
                    .frame(width: 18, height: 18)
                if !isLast {
                    Rectangle()
                        .fill(AppTheme.Colors.border)
                        .frame(width: 2)
                }
            }
            .frame(width: 18)
            .padding(.trailing, 4)

            // Card skeleton
            VStack(alignment: .leading, spacing: 8) {
                // Header skeleton
                HStack {
                    SkeletonBlock(width: 120, height: 14)
                    Spacer()
                    SkeletonBlock(width: 50, height: 11)
                }

                // Card body
                VStack(alignment: .leading, spacing: 0) {
                    // AI summary area
                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonBlock(width: 45, height: 9)
                        VStack(alignment: .leading, spacing: 6) {
                            SkeletonBlock(height: 10)
                            SkeletonBlock(width: 200, height: 10)
                            SkeletonBlock(width: 140, height: 10)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.aiCardBackground)

                    // Activity bar
                    SkeletonBlock(height: 4)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)

                    // Stats row
                    HStack(spacing: 8) {
                        SkeletonBlock(width: 35, height: 10)
                        SkeletonBlock(width: 55, height: 10)
                        Spacer()
                        SkeletonBlock(width: 30, height: 10)
                        SkeletonBlock(width: 25, height: 10)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppTheme.Colors.border).frame(height: 1)
                    }
                }
                .background(AppTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
            }
        }
        .padding(.bottom, 16)
    }
}
