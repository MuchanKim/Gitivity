import SwiftUI

struct AIErrorInlineView: View {
    let error: Error
    var onRetry: (() async -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(StringLiterals.AI.summaryLabel)
                .font(AppTheme.Fonts.label)
                .foregroundStyle(AppTheme.Colors.aiLabel)
                .tracking(0.5)

            Text(errorMessage)
                .font(AppTheme.Fonts.cardBody)
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .lineSpacing(4)

            if showRetry {
                Button {
                    Task { await onRetry?() }
                } label: {
                    Text(StringLiterals.AI.retryGeneration)
                        .font(AppTheme.Fonts.sectionTitle)
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                .padding(.top, 4)
            }

            if showSettingsLink, let url = URL(string: UIApplication.openSettingsURLString) {
                Link(destination: url) {
                    Text(StringLiterals.AI.enableInSettings)
                        .font(AppTheme.Fonts.sectionTitle)
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                .padding(.top, 4)
            }
        }
    }

    private var errorMessage: String {
        if let aiError = error as? AIProviderError {
            return switch aiError {
            case .modelUnavailable:
                StringLiterals.AI.inlineDeviceNotEligible
            case .contextWindowExceeded:
                StringLiterals.AI.inlineContextWindowExceeded
            case .unsupportedLocale:
                StringLiterals.AI.inlineUnsupportedLocale
            case .generationFailed:
                StringLiterals.AI.inlineGenerationFailed
            }
        }
        return StringLiterals.AI.inlineGenerationFailed
    }

    private var showRetry: Bool {
        if let aiError = error as? AIProviderError, case .generationFailed = aiError {
            return true
        }
        return false
    }

    private var showSettingsLink: Bool {
        if let aiError = error as? AIProviderError, case .modelUnavailable = aiError {
            return true
        }
        return false
    }
}
