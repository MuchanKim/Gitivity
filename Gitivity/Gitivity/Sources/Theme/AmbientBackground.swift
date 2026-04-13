import SwiftUI

struct AmbientBackground: View {
    var body: some View {
        ZStack {
            AppTheme.Colors.background

            RadialGradient(
                colors: [AppTheme.Colors.primary.opacity(0.045), .clear],
                center: .init(x: 0.5, y: 0.12),
                startRadius: 0,
                endRadius: 400
            )

            RadialGradient(
                colors: [Color(hex: 0x3B82F6).opacity(0.03), .clear],
                center: .init(x: 0.25, y: 0.5),
                startRadius: 0,
                endRadius: 300
            )

            RadialGradient(
                colors: [Color(hex: 0xA78BFA).opacity(0.025), .clear],
                center: .init(x: 0.8, y: 0.7),
                startRadius: 0,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}
