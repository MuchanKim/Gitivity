import SwiftUI
import FoundationModels

struct AIUnavailableView: View {
    private let availability = SystemLanguageModel.default.availability

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            switch availability {
            case .available:
                EmptyView()

            case .unavailable(.deviceNotEligible):
                unavailableContent(
                    icon: "xmark.circle",
                    title: StringLiterals.AI.deviceNotEligibleTitle,
                    description: StringLiterals.AI.deviceNotEligibleDescription,
                    showSettingsLink: false,
                    showProgress: false
                )

            case .unavailable(.appleIntelligenceNotEnabled):
                unavailableContent(
                    icon: "✦",
                    title: StringLiterals.AI.intelligenceNotEnabledTitle,
                    description: StringLiterals.AI.intelligenceNotEnabledDescription,
                    showSettingsLink: true,
                    showProgress: false
                )

            case .unavailable(.modelNotReady):
                unavailableContent(
                    icon: "arrow.down.circle",
                    title: StringLiterals.AI.modelNotReadyTitle,
                    description: StringLiterals.AI.modelNotReadyDescription,
                    showSettingsLink: false,
                    showProgress: true
                )

            case .unavailable:
                unavailableContent(
                    icon: "exclamationmark.triangle",
                    title: StringLiterals.AI.unknownUnavailableTitle,
                    description: StringLiterals.AI.unknownUnavailableDescription,
                    showSettingsLink: false,
                    showProgress: false
                )
            }
        }
    }

    private func unavailableContent(
        icon: String,
        title: String,
        description: String,
        showSettingsLink: Bool,
        showProgress: Bool
    ) -> some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: 0x1E1B4B))
                .frame(width: 72, height: 72)
                .overlay {
                    if icon.count <= 2 {
                        Text(icon).font(AppTheme.Fonts.onboardingIcon)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                    }
                }

            Text(title)
                .font(AppTheme.Fonts.profileName)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(description)
                .font(AppTheme.Fonts.stats)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if showSettingsLink, let url = URL(string: UIApplication.openSettingsURLString) {
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

            if showProgress {
                ProgressView()
                    .tint(.white)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 30)
    }
}
