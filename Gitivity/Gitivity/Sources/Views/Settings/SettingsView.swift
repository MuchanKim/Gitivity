import SwiftUI

struct SettingsView: View {
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
                    Text("GitHub 계정 관리")
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
