import SwiftUI

struct BudgetOverviewView: View {
    @StateObject private var viewModel: BudgetOverviewViewModel
    @State private var showZeroBasedBudget = false

    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        _viewModel = StateObject(wrappedValue: BudgetOverviewViewModel(
            transactionRepository: transactionRepository,
            budgetRepository: budgetRepository
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    monthlySummaryCard

                    categoryBreakdownCard
                }
                .padding(.horizontal, DesignTokens.Spacing.m)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        NavigationLink {
                            BudgetSettingsView(budgetRepository: viewModel.budgetRepository)
                        } label: {
                            Label("Budget Settings", systemImage: "slider.horizontal.3")
                        }
                        
                        Button {
                            showZeroBasedBudget = true
                        } label: {
                            Label("Zero-Based Budget", systemImage: "dollarsign.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showZeroBasedBudget) {
                IncomeAllocationView(
                    transactionRepository: viewModel.transactionRepository,
                    budgetRepository: viewModel.budgetRepository
                )
            }
        }
    }

    private var monthlySummaryCard: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Text("This Month")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.remainingThisMonth.currencyFormatted)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.budgetProgress < 0.8 ? Color.primary : Color.expenseRed)

            VStack(spacing: DesignTokens.Spacing.xs) {
                HStack {
                    Text("Spent")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.spentThisMonth.currencyFormatted)
                        .font(.subheadline.bold())
                }

                HStack {
                    Text("Budget")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.monthlyBudget.currencyFormatted)
                        .font(.subheadline.bold())
                }
            }

            ProgressBar(
                progress: viewModel.budgetProgress,
                color: viewModel.budgetProgress < 0.5 ? .incomeGreen : viewModel.budgetProgress < 0.8 ? .warningOrange : .expenseRed,
                height: 10
            )

            Text("\(Int(viewModel.budgetProgress * 100))% of budget used")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("By Category")
                .font(.headline)

            if viewModel.categorySpending.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: DesignTokens.Spacing.s) {
                        Image(systemName: "chart.pie")
                            .font(.title2)
                            .foregroundStyle(.tertiary)
                        Text("No spending yet this month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, DesignTokens.Spacing.l)
            } else {
                ForEach(viewModel.categorySpending) { spending in
                    CategoryBudgetRow(spending: spending)
                }
            }
        }
        .cardStyle()
    }
}
