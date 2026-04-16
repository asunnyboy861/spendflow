import SwiftUI

struct AccountCard: View {
    let account: Account

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: account.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: account.color))
                .frame(width: 44, height: 44)
                .background(Color(hex: account.color).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.subheadline.bold())
                if let institution = account.institution {
                    Text(institution)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(displayBalance)
                .font(.subheadline.bold())
                .foregroundStyle(account.type == .credit ? Color.expenseRed : Color.primary)
        }
        .padding(.vertical, DesignTokens.Spacing.s)
    }

    private var displayBalance: String {
        let amount = account.type == .credit ? -account.balance : account.balance
        return amount.currencyFormatted
    }
}
