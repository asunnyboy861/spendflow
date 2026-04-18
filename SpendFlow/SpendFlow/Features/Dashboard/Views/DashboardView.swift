import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @StateObject private var billViewModel: BillReminderViewModel
    @State private var showAddTransaction = false
    @State private var showBillReminder = false
    
    private let suggestionService: CategorySuggestionService

    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository,
        accountRepository: AccountRepository,
        suggestionService: CategorySuggestionService
    ) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            transactionRepository: transactionRepository,
            budgetRepository: budgetRepository,
            accountRepository: accountRepository
        ))
        _billViewModel = StateObject(wrappedValue: BillReminderViewModel(
            repository: BillReminderRepository(),
            reminderService: BillReminderService()
        ))
        self.suggestionService = suggestionService
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
                    
                    if !billViewModel.overdueBills.isEmpty || !billViewModel.upcomingBills.isEmpty {
                        billsPreviewCard
                    }

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
                AddTransactionView(
                    transactionRepository: viewModel.transactionRepository,
                    suggestionService: suggestionService
                )
            }
            .sheet(isPresented: $showBillReminder) {
                NavigationStack {
                    BillReminderView()
                }
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
    
    private var billsPreviewCard: some View {
        VStack(spacing: DesignTokens.Spacing.s) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundStyle(.warningOrange)
                Text("Upcoming Bills")
                    .font(.headline)
                
                Spacer()
                
                Button("View All") {
                    showBillReminder = true
                }
                .font(.subheadline)
                .fontWeight(.medium)
            }
            
            let urgentBills = (billViewModel.overdueBills + billViewModel.upcomingBills).prefix(3)
            
            ForEach(urgentBills) { bill in
                HStack {
                    Circle()
                        .fill(Color(hex: bill.status.color))
                        .frame(width: 8, height: 8)
                    
                    Text(bill.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(bill.amount.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(bill.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(DesignTokens.Spacing.m)
        .cardStyle()
    }
}
