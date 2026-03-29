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
                    Text("AI 모델")
                    Spacer()
                    Text("Foundation")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Image(systemName: "chevron.right")
                        .font(AppTheme.Fonts.stats)
                        .foregroundStyle(AppTheme.Colors.textMeta)
                }
            } header: {
                Text("AI")
            }

            // General Section
            Section {
                HStack {
                    settingsIcon("🔒", background: AppTheme.Colors.cardBackground, foreground: AppTheme.Colors.textTertiary)
                    Text("개인정보 처리방침")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(AppTheme.Fonts.stats)
                        .foregroundStyle(AppTheme.Colors.textMeta)
                }

                HStack {
                    settingsIcon("ℹ️", background: AppTheme.Colors.cardBackground, foreground: AppTheme.Colors.textTertiary)
                    Text("앱 정보")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            } header: {
                Text("일반")
            }

            // Account Section
            Section {
                Button {
                    authViewModel.signOut()
                } label: {
                    HStack {
                        settingsIcon("↩️", background: AppTheme.Colors.cardBackground, foreground: AppTheme.Colors.textTertiary)
                        Text("로그아웃")
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
                }

                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        settingsIcon("✕", background: Color(hex: 0x2D1215), foreground: AppTheme.Colors.danger)
                        VStack(alignment: .leading) {
                            Text("계정 삭제")
                                .foregroundStyle(AppTheme.Colors.danger)
                            Text("모든 데이터가 삭제됩니다")
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                }
            } header: {
                Text("계정")
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("계정을 삭제하시겠습니까?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("Keychain 토큰이 삭제되고 로그아웃됩니다. 이 작업은 되돌릴 수 없습니다.")
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
