import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            // AI Section
            Section {
                HStack {
                    settingsIcon("✦", background: Color(hex: 0x1E1B4B), foreground: Color(hex: 0xA78BFA))
                    Text(StringLiterals.Settings.aiModel)
                    Spacer()
                    Text(StringLiterals.Settings.aiModelValue)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Image(systemName: "chevron.right")
                        .font(AppTheme.Fonts.stats)
                        .foregroundStyle(AppTheme.Colors.textMeta)
                }
            } header: {
                Text(StringLiterals.Settings.sectionAI)
            }

            // General Section
            Section {
                HStack {
                    settingsIcon("🔒", background: AppTheme.Colors.cardBackground, foreground: AppTheme.Colors.textTertiary)
                    Text(StringLiterals.Settings.privacyPolicy)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(AppTheme.Fonts.stats)
                        .foregroundStyle(AppTheme.Colors.textMeta)
                }

                HStack {
                    settingsIcon("ℹ️", background: AppTheme.Colors.cardBackground, foreground: AppTheme.Colors.textTertiary)
                    Text(StringLiterals.Settings.appInfo)
                    Spacer()
                    Text(StringLiterals.Settings.appVersion)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            } header: {
                Text(StringLiterals.Settings.sectionGeneral)
            }

            // Account Section
            Section {
                Button {
                    authViewModel.signOut()
                } label: {
                    HStack {
                        settingsIcon("↩️", background: AppTheme.Colors.cardBackground, foreground: AppTheme.Colors.textTertiary)
                        Text(StringLiterals.Settings.signOut)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
                }

                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        settingsIcon("✕", background: Color(hex: 0x2D1215), foreground: AppTheme.Colors.danger)
                        VStack(alignment: .leading) {
                            Text(StringLiterals.Settings.deleteAccount)
                                .foregroundStyle(AppTheme.Colors.danger)
                            Text(StringLiterals.Settings.deleteAccountWarning)
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                }
            } header: {
                Text(StringLiterals.Settings.sectionAccount)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background)
        .navigationTitle(StringLiterals.Settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(StringLiterals.Settings.deleteAccountConfirm, isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(StringLiterals.Settings.deleteButton, role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text(StringLiterals.Settings.deleteAccountDetail)
        }
    }

    private func settingsIcon(_ icon: String, background: Color, foreground: Color) -> some View {
        Text(icon)
            .font(AppTheme.Fonts.timestamp)
            .frame(width: 28, height: 28)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func deleteAccount() async {
        let keychain = KeychainService()
        try? keychain.delete(key: "github_token")
        authViewModel.signOut()
    }
}
