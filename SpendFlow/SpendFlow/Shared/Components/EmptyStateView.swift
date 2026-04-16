import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionLabel: String?
    let action: (() -> Void)?

    init(icon: String, title: String, subtitle: String, actionLabel: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionLabel = actionLabel
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.l) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            VStack(spacing: DesignTokens.Spacing.s) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }

            if let actionLabel, let action {
                HapticButton(actionLabel, action: action)
                    .padding(.horizontal, DesignTokens.Spacing.xl)
            }
        }
        .padding(DesignTokens.Spacing.xxl)
    }
}
