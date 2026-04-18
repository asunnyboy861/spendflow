import SwiftUI

struct BankConnectionView: View {
    @StateObject private var viewModel: BankSyncSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(
        bankSyncService: BankSyncService,
        transactionRepository: TransactionRepository
    ) {
        _viewModel = StateObject(wrappedValue: BankSyncSettingsViewModel(
            bankSyncService: bankSyncService,
            transactionRepository: transactionRepository
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    statusCard
                    
                    if viewModel.hasConnectedBanks {
                        connectedAccountsSection
                    } else {
                        emptyStateView
                    }
                    
                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Bank Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
        }
    }
    
    private var statusCard: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: viewModel.syncStatus.icon)
                .font(.system(size: 48))
                .foregroundStyle(viewModel.syncStatus.color)
            
            Text(viewModel.syncStatus.displayText)
                .font(.headline)
            
            if viewModel.hasConnectedBanks {
                HStack(spacing: DesignTokens.Spacing.m) {
                    VStack {
                        Text("\(viewModel.connectedAccounts.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Accounts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack {
                        Text(totalBalance.currencyFormatted)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Total Balance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HapticButton("Sync All Accounts", style: .primary) {
                    viewModel.syncAllAccounts()
                }
                .disabled(viewModel.isLoading)
            } else {
                HapticButton("Connect Bank Account", style: .primary) {
                    viewModel.connectBank()
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private var connectedAccountsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("Connected Accounts")
                .font(.headline)
            
            ForEach(viewModel.connectedAccounts) { account in
                BankAccountRow(
                    account: account,
                    onSync: {
                        viewModel.syncAccount(account.id)
                    },
                    onDisconnect: {
                        viewModel.disconnectAccount(account.id)
                    }
                )
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Banks Connected")
                .font(.headline)
            
            Text("Connect your bank account to automatically import transactions")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Note: This feature requires backend integration with Plaid API")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.xl)
        .cardStyle()
    }
    
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.expenseRed)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button {
                viewModel.errorMessage = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(DesignTokens.Spacing.m)
        .background(Color.expenseRed.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.m) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Processing...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(DesignTokens.Spacing.xl)
            .background(Color.black.opacity(0.7))
            .cornerRadius(16)
        }
    }
    
    private var totalBalance: Double {
        viewModel.connectedAccounts.map { $0.balance }.reduce(0, +)
    }
}

#Preview {
    let bankSyncService = MockBankSyncService()
    let transactionRepo = TransactionRepositoryImpl()
    
    return BankConnectionView(
        bankSyncService: bankSyncService,
        transactionRepository: transactionRepo
    )
}
