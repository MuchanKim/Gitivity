import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("잔디 테마") {
                    Text("컬러 선택")
                }

                Section("AI Provider") {
                    Text("Foundation Models (On-Device)")
                }

                Section("계정") {
                    Button("로그아웃", role: .destructive) {
                        Task { await authViewModel.signOut() }
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthViewModel())
}
