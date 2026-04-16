import SwiftUI

struct RecentTransactionsList: View {
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
            }

            if transactions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: DesignTokens.Spacing.s) {
                        Image(systemName: "receipt")
                            .font(.title2)
                            .foregroundStyle(.tertiary)
                        Text("No transactions yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, DesignTokens.Spacing.l)
            } else {
                VStack(spacing: DesignTokens.Spacing.s) {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
    }
}
