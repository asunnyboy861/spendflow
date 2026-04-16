import Combine
import Foundation

class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var searchText: String = ""
    @Published var selectedType: TransactionType? = nil
    @Published var selectedCategory: String? = nil

    let transactionRepository: TransactionRepository
    private var cancellables = Set<AnyCancellable>()

    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository

        transactionRepository.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.transactions = transactions
                self?.applyFilters()
            }
            .store(in: &cancellables)

        loadTransactions()
    }

    func loadTransactions() {
        transactions = transactionRepository.fetchAll()
        applyFilters()
    }

    func applyFilters() {
        var result = transactions

        if let selectedType {
            result = result.filter { $0.type == selectedType }
        }

        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                ($0.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        filteredTransactions = result
    }

    func deleteTransaction(_ transaction: Transaction) {
        do {
            try transactionRepository.delete(transaction)
            HapticFeedback.medium()
        } catch {
            HapticFeedback.error()
        }
    }
}
