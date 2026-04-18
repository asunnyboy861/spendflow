import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel: InsightsViewModel
    @State private var selectedTab: InsightsTab = .spending
    
    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        _viewModel = StateObject(wrappedValue: InsightsViewModel(
            transactionRepository: transactionRepository,
            budgetRepository: budgetRepository
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    periodSelector
                    
                    tabSelector
                    
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        contentSection
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadData()
            }
        }
    }
    
    private var periodSelector: some View {
        Picker("Period", selection: $viewModel.selectedPeriod) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            viewModel.loadData()
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(InsightsTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Text(tab.title)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.bottom, DesignTokens.Spacing.s)
    }
    
    @ViewBuilder
    private var contentSection: some View {
        switch selectedTab {
        case .spending:
            if viewModel.categorySpending.isEmpty {
                emptyStateView(message: "No spending data for this period")
            } else {
                CategoryPieChart(categorySpending: viewModel.categorySpending)
            }
            
        case .trend:
            if viewModel.monthlyData.isEmpty {
                emptyStateView(message: "No trend data available")
            } else {
                MonthlyTrendChart(monthlyData: viewModel.monthlyData)
            }
            
        case .budget:
            if viewModel.budgetComparison.isEmpty {
                emptyStateView(message: "No budgets set")
            } else {
                BudgetComparisonChart(budgetComparison: viewModel.budgetComparison)
            }
            
        case .netWorth:
            NetWorthView()
            
        case .health:
            FinancialHealthView(
                transactionRepository: viewModel.transactionRepository,
                budgetRepository: viewModel.budgetRepository
            )
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Start adding transactions to see insights")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.xl)
        .cardStyle()
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading insights...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}

enum InsightsTab: CaseIterable {
    case spending
    case trend
    case budget
    case netWorth
    case health
    
    var title: String {
        switch self {
        case .spending: return "Spending"
        case .trend: return "Trend"
        case .budget: return "Budget"
        case .netWorth: return "Net Worth"
        case .health: return "Health"
        }
    }
}

#Preview {
    let transactionRepo = TransactionRepositoryImpl()
    let budgetRepo = BudgetRepositoryImpl()
    
    return InsightsView(
        transactionRepository: transactionRepo,
        budgetRepository: budgetRepo
    )
}
