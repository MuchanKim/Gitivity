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

                Text(StringLiterals.AI.unavailableTitle)
                    .font(AppTheme.Fonts.profileName)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(StringLiterals.AI.unavailableDescription)
                    .font(AppTheme.Fonts.stats)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Link(destination: url) {
                        Text(StringLiterals.AI.enableInSettings)
                            .font(AppTheme.Fonts.sectionTitle)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppTheme.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }

                Text(StringLiterals.AI.deviceRequirement)
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textMeta)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
        }
    }
}
