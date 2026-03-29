import SwiftUI

struct OnboardingPageView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                onboardingPage(
                    icon: "✦",
                    title: "내가 만든 것을\n이해하는 방법",
                    description: "AI가 커밋과 PR을\n사람의 말로 요약해줍니다"
                )
                .tag(0)

                onboardingPage(
                    icon: "📊",
                    title: "레포별 타임라인",
                    description: "최근 작업한 레포를\n활동 분류와 함께 확인"
                )
                .tag(1)

                loginPage()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            // Skip button
            if currentPage < 2 {
                VStack {
                    HStack {
                        Spacer()
                        Button("건너뛰기") {
                            withAnimation { currentPage = 2 }
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.primary)
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 8)
                    Spacer()
                }
            }
        }
    }

    private func onboardingPage(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text(icon)
                .font(.system(size: 44))
            Text(title)
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(description)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 30)
    }

    private func loginPage() -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🔒")
                .font(.system(size: 44))
            Text("온디바이스 AI")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.white)
            Text("데이터가 기기를 떠나지 않습니다")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Spacer()

            Button {
                Task { await authViewModel.signIn() }
            } label: {
                HStack(spacing: 8) {
                    Text("🐙")
                    Text("GitHub로 시작하기")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: 260)
                .padding(.vertical, 14)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(authViewModel.isLoading)

            if authViewModel.isLoading {
                ProgressView().tint(.white)
            }

            if let error = authViewModel.error {
                Text(error).font(.caption).foregroundStyle(AppTheme.Colors.danger)
            }

            Text("계속하면 개인정보 처리방침에 동의하는 것으로 간주됩니다.")
                .font(.system(size: 9))
                .foregroundStyle(AppTheme.Colors.textMeta)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 30)
    }
}
