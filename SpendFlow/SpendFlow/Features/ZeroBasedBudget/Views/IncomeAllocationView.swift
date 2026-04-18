import SwiftUI

struct IncomeAllocationView: View {
    @StateObject private var viewModel: ZeroBasedBudgetViewModel
    @State private var showTransferSheet = false
    @State private var transferFrom = ""
    @State private var transferTo = ""
    @State private var transferAmount = ""
    
    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        _viewModel = StateObject(wrappedValue: ZeroBasedBudgetViewModel(
            transactionRepository: transactionRepository,
            budgetRepository: budgetRepository,
            ageOfMoneyCalculator: AgeOfMoneyCalculator()
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.l) {
                incomeSummaryCard
                
                AgeOfMoneyCard(ageOfMoney: viewModel.ageOfMoney)
                
                allocationSection
                
                unallocatedSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Zero-Based Budget")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showTransferSheet = true
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                }
            }
        }
        .sheet(isPresented: $showTransferSheet) {
            transferSheet
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    private var incomeSummaryCard: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Text("Monthly Income")
                .font(.headline)
            
            Text(viewModel.totalIncome.currencyFormatted)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            
            HStack(spacing: DesignTokens.Spacing.l) {
                VStack(spacing: 4) {
                    Text("Allocated")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.totalAllocated.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.accentBlue)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("Unallocated")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.totalUnallocated.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.totalUnallocated >= 0 ? .incomeGreen : .expenseRed)
                }
            }
            
            ProgressView(value: viewModel.totalIncome > 0 ? viewModel.totalAllocated / viewModel.totalIncome : 0)
                .tint(viewModel.totalAllocated >= viewModel.totalIncome ? .incomeGreen : .accentBlue)
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private var allocationSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("Budget Allocations")
                .font(.headline)
            
            if viewModel.allocations.isEmpty {
                EmptyStateView(
                    icon: "chart.pie",
                    title: "No Budgets Set",
                    subtitle: "Set up budgets in Budget Settings to see allocations"
                )
            } else {
                ForEach(viewModel.allocations) { allocation in
                    BudgetAllocationRow(allocation: allocation)
                }
            }
        }
    }
    
    private var unallocatedSection: some View {
        Group {
            if viewModel.totalUnallocated > 0 {
                VStack(spacing: DesignTokens.Spacing.m) {
                    HStack {
                        Text("Ready to Assign")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(viewModel.totalUnallocated.currencyFormatted)
                            .font(.headline)
                            .foregroundStyle(.incomeGreen)
                    }
                    
                    Text("Assign your unallocated income to budget categories to give every dollar a job.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(DesignTokens.Spacing.l)
                .cardStyle()
            }
        }
    }
    
    private var transferSheet: some View {
        NavigationStack {
            Form {
                Section("Transfer From") {
                    Picker("Category", selection: $transferFrom) {
                        Text("Select category").tag("")
                        ForEach(viewModel.allocations.filter { $0.allocated > 0 }) { allocation in
                            Text("\(allocation.category) (\(allocation.remaining.currencyFormatted))").tag(allocation.category)
                        }
                    }
                }
                
                Section("Transfer To") {
                    Picker("Category", selection: $transferTo) {
                        Text("Select category").tag("")
                        ForEach(viewModel.allocations) { allocation in
                            Text(allocation.category).tag(allocation.category)
                        }
                    }
                }
                
                Section("Amount") {
                    TextField("Amount", text: $transferAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    HapticButton("Transfer") {
                        if let amount = Double(transferAmount), !transferFrom.isEmpty, !transferTo.isEmpty {
                            viewModel.transferBudget(from: transferFrom, to: transferTo, amount: amount)
                            showTransferSheet = false
                        }
                    }
                    .disabled(transferFrom.isEmpty || transferTo.isEmpty || transferAmount.isEmpty || transferFrom == transferTo)
                }
            }
            .navigationTitle("Transfer Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showTransferSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        IncomeAllocationView(
            transactionRepository: TransactionRepositoryImpl(),
            budgetRepository: BudgetRepositoryImpl()
        )
    }
}
