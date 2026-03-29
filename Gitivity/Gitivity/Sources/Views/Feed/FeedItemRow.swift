import SwiftUI

struct FeedItemRow: View {
    let item: FeedItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.repositoryName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    if item.additions > 0 || item.deletions > 0 {
                        HStack(spacing: 4) {
                            Text("+\(item.additions)")
                                .foregroundStyle(.green)
                            Text("-\(item.deletions)")
                                .foregroundStyle(.red)
                        }
                        .font(.caption.monospacedDigit())
                    }

                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch item.type {
        case .pullRequest: "arrow.triangle.merge"
        case .push: "arrow.up.circle"
        case .issue: "exclamationmark.circle"
        }
    }

    private var iconColor: Color {
        switch item.type {
        case .pullRequest: .purple
        case .push: .blue
        case .issue: .green
        }
    }
}
