import SwiftUI

struct FeedDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI 요약")
                    .font(.title2)

                Text("변경 사항")
                    .font(.title2)

                Text("로우 데이터")
                    .font(.title2)
            }
            .padding()
        }
        .navigationTitle("상세")
    }
}

#Preview {
    NavigationStack {
        FeedDetailView()
    }
}
