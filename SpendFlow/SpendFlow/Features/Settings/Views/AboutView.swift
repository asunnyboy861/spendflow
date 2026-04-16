import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            Image(systemName: "flowchart.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: DesignTokens.Spacing.xs) {
                Text("SpendFlow")
                    .font(.title.bold())
                Text("Real-Time Budget Tracker")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("See how much you can spend at a glance.\nSpendFlow helps you track your budget in real-time with minimal effort.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.xl)

            Text("Version \(AppConstants.appVersion)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
