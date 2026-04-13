import SwiftUI

struct CardModifier: ViewModifier {
    var isPrimary: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(AppTheme.CardStyle.backgroundGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.CardStyle.borderGradient, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: isPrimary ? 8 : 4, y: isPrimary ? 4 : 2)
            .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
    }
}

extension View {
    func cardStyle(isPrimary: Bool = false) -> some View {
        modifier(CardModifier(isPrimary: isPrimary))
    }
}
