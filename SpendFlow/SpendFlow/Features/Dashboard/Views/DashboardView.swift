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
                if UIDevice.current.userInterfaceIdiom == .pad {
                    iPadContent
                } else {
                    iPhoneContent
                }
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
                .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? DesignTokens.Spacing.l : DesignTokens.Spacing.m)
                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? DesignTokens.Spacing.xl : DesignTokens.Spacing.l)
            }
        }
    }
    
    @ViewBuilder
    private var iPadContent: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            HStack(spacing: DesignTokens.Spacing.xl) {
                RemainingBudgetCard(
                    remaining: viewModel.remainingThisMonth,
                    total: viewModel.spentThisMonth,
                    progress: viewModel.budgetProgress,
                    period: "This Month"
                )
                .frame(maxWidth: .infinity)
                
                if !billViewModel.overdueBills.isEmpty || !billViewModel.upcomingBills.isEmpty {
                    billsPreviewCard
                        .frame(maxWidth: .infinity)
                }
            }
            
            HStack(spacing: DesignTokens.Spacing.xl) {
                RecentTransactionsList(transactions: viewModel.recentTransactions)
                    .frame(maxWidth: .infinity)
                
                quickActionsCard
                    .frame(width: 280)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 16)
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    private var iPhoneContent: some View {
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
    
    private var quickActionsCard: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: DesignTokens.Spacing.s) {
                quickActionButton(icon: "plus.circle.fill", title: "Add Expense", color: .accentColor) {
                    showAddTransaction = true
                }
                
                quickActionButton(icon: "chart.pie.fill", title: "View Budget", color: .blue) {
                    // Navigate to budget
                }
                
                quickActionButton(icon: "bell.badge.fill", title: "Bill Reminders", color: .orange) {
                    showBillReminder = true
                }
                
                quickActionButton(icon: "chart.bar.xaxis", title: "Insights", color: .purple) {
                    // Navigate to insights
                }
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)
                Text(title)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, DesignTokens.Spacing.s)
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
