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
                    title: StringLiterals.Onboarding.pageTitle,
                    description: StringLiterals.Onboarding.pageDescription
                )
                .tag(0)

                onboardingPage(
                    icon: "📊",
                    title: StringLiterals.Onboarding.timelineTitle,
                    description: StringLiterals.Onboarding.timelineDescription
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
                        Button(StringLiterals.Onboarding.skip) {
                            withAnimation { currentPage = 2 }
                        }
                        .font(AppTheme.Fonts.skipButton)
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
                .font(AppTheme.Fonts.onboardingIcon)
            Text(title)
                .font(AppTheme.Fonts.onboardingTitle)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(description)
                .font(AppTheme.Fonts.onboardingBody)
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
                .font(AppTheme.Fonts.onboardingIcon)
            Text(StringLiterals.Onboarding.onDeviceAI)
                .font(AppTheme.Fonts.onboardingTitle)
                .foregroundStyle(.white)
            Text(StringLiterals.Onboarding.dataPrivacy)
                .font(AppTheme.Fonts.onboardingBody)
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Spacer()

            Button {
                Task { await authViewModel.signIn() }
            } label: {
                HStack(spacing: 8) {
                    Text("🐙")
                    Text(StringLiterals.Onboarding.signInWithGitHub)
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

            Text(StringLiterals.Onboarding.privacyConsent)
                .font(AppTheme.Fonts.privacyNotice)
                .foregroundStyle(AppTheme.Colors.textMeta)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 30)
    }
}
