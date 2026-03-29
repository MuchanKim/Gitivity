import SwiftUI
import FoundationModels

struct AIUnavailableView: View {
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: 0x1E1B4B))
                    .frame(width: 72, height: 72)
                    .overlay {
                        Text("✦").font(AppTheme.Fonts.onboardingIcon)
                    }

                Text("Apple Intelligence\n필요")
                    .font(AppTheme.Fonts.profileName)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Gitivity는 온디바이스 AI를 사용하여\nGitHub 활동을 요약합니다.\n\n이 기능을 사용하려면\nApple Intelligence가 필요합니다.")
                    .font(AppTheme.Fonts.stats)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Link(destination: url) {
                        Text("설정에서 활성화하기")
                            .font(AppTheme.Fonts.sectionTitle)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppTheme.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }

                Text("iPhone 15 Pro 이상 기기에서\n사용할 수 있습니다")
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textMeta)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
        }
    }
}
