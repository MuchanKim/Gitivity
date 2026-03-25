import SwiftUI

struct OnboardingView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Gitivity")
                .font(.largeTitle.bold())

            Text("GitHub 활동을 AI가 정리해주는\n나만의 개발 회고 도구")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                Task { await authViewModel.signIn() }
            } label: {
                HStack(spacing: 8) {
                    if authViewModel.isLoading {
                        ProgressView()
                    }
                    Text("GitHub로 로그인")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(authViewModel.isLoading)

            if let error = authViewModel.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()
                .frame(height: 40)
        }
        .padding(24)
    }
}

#Preview {
    OnboardingView()
        .environment(AuthViewModel())
}
