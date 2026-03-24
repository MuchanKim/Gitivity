import SwiftUI

struct SummaryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ContributionGraphView()

                    SummaryCardView()
                }
                .padding()
            }
            .navigationTitle("요약")
        }
    }
}

#Preview {
    SummaryView()
}
