import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var showAddTransaction = false

    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository,
        accountRepository: AccountRepository
    ) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            transactionRepository: transactionRepository,
            budgetRepository: budgetRepository,
            accountRepository: accountRepository
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    RemainingBudgetCard(
                        remaining: viewModel.remainingThisMonth,
                        total: viewModel.spentThisMonth,
                        progress: viewModel.budgetProgress,
                        period: "This Month"
                    )

                    RecentTransactionsList(transactions: viewModel.recentTransactions)
                }
                .padding(.horizontal, DesignTokens.Spacing.m)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SpendFlow")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(transactionRepository: viewModel.transactionRepository)
            }
            .overlay(alignment: .bottomTrailing) {
                QuickAddButton {
                    showAddTransaction = true
                }
                .padding(.trailing, DesignTokens.Spacing.m)
                .padding(.bottom, DesignTokens.Spacing.l)
            }
        }
    }
}
