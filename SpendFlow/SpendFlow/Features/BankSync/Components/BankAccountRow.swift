import SwiftUI

struct BankAccountRow: View {
    let account: BankAccount
    let onSync: () -> Void
    let onDisconnect: () -> Void
    
    @State private var showingActions: Bool = false
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: account.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: account.accountType.color))
                .frame(width: 40, height: 40)
                .background(Color(hex: account.accountType.color).opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(account.accountName)
                    .font(.headline)
                
                Text(account.bankName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(account.balance.currencyFormatted)
                    .font(.headline)
                    .foregroundStyle(account.balance >= 0 ? Color.primary : Color.expenseRed)
                
                if let lastSync = account.lastSyncDate {
                    Text("Synced \(lastSync, style: .relative)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(DesignTokens.Spacing.m)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture {
            showingActions = true
        }
        .confirmationDialog("Account Actions", isPresented: $showingActions) {
            Button("Sync Now") {
                onSync()
            }
            
            Button("Disconnect", role: .destructive) {
                onDisconnect()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("What would you like to do with \(account.displayName)?")
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        BankAccountRow(
            account: BankAccount(
                plaidAccountId: "test-1",
                bankName: "Chase",
                accountName: "Checking",
                accountType: .checking,
                accountSubtype: "checking",
                balance: 5432.10,
                lastSyncDate: Date()
            ),
            onSync: {},
            onDisconnect: {}
        )
        
        BankAccountRow(
            account: BankAccount(
                plaidAccountId: "test-2",
                bankName: "Chase",
                accountName: "Freedom Unlimited",
                accountType: .credit,
                accountSubtype: "credit card",
                balance: -1234.56,
                lastSyncDate: Date()
            ),
            onSync: {},
            onDisconnect: {}
        )
    }
    .padding()
}
