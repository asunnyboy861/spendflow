import SwiftUI

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?

    init(icon: String, iconColor: Color = .accentColor, title: String, value: String? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            Text(title)
                .font(.body)

            Spacer()

            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
