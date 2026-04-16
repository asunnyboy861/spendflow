import SwiftUI

struct TransactionListView: View {
    @StateObject private var viewModel: TransactionListViewModel
    @State private var showAddTransaction = false

    init(transactionRepository: TransactionRepository) {
        _viewModel = StateObject(wrappedValue: TransactionListViewModel(
            transactionRepository: transactionRepository
        ))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredTransactions.isEmpty {
                    EmptyStateView(
                        icon: "receipt",
                        title: "No Transactions",
                        subtitle: "Add your first transaction to start tracking your spending",
                        actionLabel: "Add Transaction"
                    ) {
                        showAddTransaction = true
                    }
                } else {
                    List {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Transactions")
            .searchable(text: $viewModel.searchText, prompt: "Search transactions")
            .onChange(of: viewModel.searchText) { _, _ in viewModel.applyFilters() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("All") {
                            viewModel.selectedType = nil
                            viewModel.applyFilters()
                        }
                        Button("Expenses") {
                            viewModel.selectedType = .expense
                            viewModel.applyFilters()
                        }
                        Button("Income") {
                            viewModel.selectedType = .income
                            viewModel.applyFilters()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(transactionRepository: viewModel.transactionRepository)
            }
        }
    }
}
