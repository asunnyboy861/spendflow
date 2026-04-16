import SwiftUI

struct SyncStatusIndicator: View {
    let status: SyncStatus

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.s) {
            Image(systemName: status.icon)
                .foregroundColor(status.color)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(status.displayText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                if case .syncing = status {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                }
            }

            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.s)
    }
}

struct SyncToggle: View {
    @Binding var isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Toggle(isOn: $isEnabled) {
            HStack(spacing: DesignTokens.Spacing.m) {
                Image(systemName: "icloud")
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small))

                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud Sync")
                        .font(.body)
                        .fontWeight(.medium)

                    Text("Sync across devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onChange(of: isEnabled) { _ in
            action()
        }
    }
}
