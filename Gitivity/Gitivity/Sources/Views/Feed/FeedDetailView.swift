import SwiftUI

struct FeedDetailView: View {
    let item: FeedItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                statsSection
                if !item.commits.isEmpty {
                    commitsSection
                }
            }
            .padding()
        }
        .navigationTitle(item.repositoryName)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(typeLabel, systemImage: typeIcon)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(item.title)
                .font(.title2.bold())
        }
    }

    private var statsSection: some View {
        HStack(spacing: 24) {
            if item.additions > 0 || item.deletions > 0 {
                VStack {
                    Text("+\(item.additions)")
                        .font(.title3.monospacedDigit().bold())
                        .foregroundStyle(.green)
                    Text("추가")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack {
                    Text("-\(item.deletions)")
                        .font(.title3.monospacedDigit().bold())
                        .foregroundStyle(.red)
                    Text("삭제")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !item.commits.isEmpty {
                VStack {
                    Text("\(item.commits.count)")
                        .font(.title3.monospacedDigit().bold())
                    Text("커밋")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(item.timestamp, style: .relative)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }

    private var commitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("커밋")
                .font(.headline)

            ForEach(item.commits) { commit in
                VStack(alignment: .leading, spacing: 4) {
                    Text(commit.message.components(separatedBy: "\n").first ?? commit.message)
                        .font(.subheadline)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(String(commit.id.prefix(7)))
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)

                        HStack(spacing: 4) {
                            Text("+\(commit.additions)")
                                .foregroundStyle(.green)
                            Text("-\(commit.deletions)")
                                .foregroundStyle(.red)
                        }
                        .font(.caption.monospacedDigit())
                    }
                }
                .padding(.vertical, 4)

                if commit.id != item.commits.last?.id {
                    Divider()
                }
            }
        }
    }

    private var typeLabel: String {
        switch item.type {
        case .pullRequest: "Pull Request"
        case .push: "Push"
        case .issue: "Issue"
        }
    }

    private var typeIcon: String {
        switch item.type {
        case .pullRequest: "arrow.triangle.merge"
        case .push: "arrow.up.circle"
        case .issue: "exclamationmark.circle"
        }
    }
}
