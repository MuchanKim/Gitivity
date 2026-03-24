import SwiftUI

struct FeedItemRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("피드 아이템")
                .font(.headline)
            Text("설명")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FeedItemRow()
}
