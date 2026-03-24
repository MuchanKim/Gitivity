import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationSplitView {
            List {
                Text("피드 아이템이 여기에 표시됩니다")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("피드")
        } detail: {
            Text("항목을 선택하세요")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    FeedView()
}
