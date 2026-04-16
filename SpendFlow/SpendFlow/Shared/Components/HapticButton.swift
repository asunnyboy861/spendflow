import SwiftUI

struct HapticButton: View {
    let action: () -> Void
    let label: String
    let style: HapticButtonStyle

    enum HapticButtonStyle {
        case primary
        case secondary
        case destructive
    }

    @State private var isPressed = false

    init(_ label: String, style: HapticButtonStyle = .primary, action: @escaping () -> Void) {
        self.label = label
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticFeedback.medium()
            action()
        }) {
            Text(label)
                .font(.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous))
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        HapticFeedback.light()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.accentColor
        case .secondary: return Color(.systemGray5)
        case .destructive: return Color.expenseRed
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return .primary
        }
    }
}
