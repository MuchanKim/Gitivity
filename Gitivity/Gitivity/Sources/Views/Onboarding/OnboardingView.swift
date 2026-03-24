import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "leaf.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Gitivity")
                .font(.largeTitle.bold())

            Text("GitHub 활동을 AI가 정리해주는\n나만의 개발 회고 도구")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("GitHub로 로그인") {
                // TODO: GitHub OAuth
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
                .frame(height: 40)
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
