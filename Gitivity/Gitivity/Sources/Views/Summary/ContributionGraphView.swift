import SwiftUI

struct ContributionGraphView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.fill.tertiary)
            .frame(height: 120)
            .overlay {
                Text("잔디밭")
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    ContributionGraphView()
        .padding()
}
