import SwiftUI

struct SummaryCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI 요약")
                .font(.headline)

            Text("이번 주 활동 요약이 여기에 표시됩니다")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}

#Preview {
    SummaryCardView()
        .padding()
}
