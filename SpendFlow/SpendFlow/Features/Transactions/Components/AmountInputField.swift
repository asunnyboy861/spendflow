import SwiftUI

struct AmountInputField: View {
    @Binding var amount: String
    let placeholder: String

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.s) {
            Text("$")
                .font(.system(size: 40, weight: .light, design: .rounded))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $amount)
                .font(.system(size: 40, weight: .light, design: .rounded))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.leading)
        }
        .padding(DesignTokens.Spacing.m)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous))
    }
}
