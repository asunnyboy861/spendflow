import Combine
import Foundation

class BudgetOverviewViewModel: ObservableObject {
    @Published var monthlyBudget: Double = 0
    @Published var spentThisMonth: Double = 0
    @Published var remainingThisMonth: Double = 0
    @Published var budgetProgress: Double = 0
    @Published var categorySpending: [CategorySpending] = []

    struct CategorySpending: Identifiable {
        let id = UUID()
        let category: String
        let icon: String
        let color: String
        let spent: Double
        let budget: Double
        var progress: Double {
            budget > 0 ? min(1.0, spent / budget) : 0
        }
    }

    let transactionRepository: TransactionRepository
    let budgetRepository: BudgetRepository
    private var cancellables = Set<AnyCancellable>()

    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository

        transactionRepository.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.loadData() }
            .store(in: &cancellables)

        loadData()
    }

    func loadData() {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        let monthTransactions = transactionRepository.fetchTransactions(from: monthStart, to: monthEnd)

        monthlyBudget = budgetRepository.fetchBudget(for: .monthly)?.amount ?? AppConstants.defaultMonthlyBudget
        spentThisMonth = monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        remainingThisMonth = max(0, monthlyBudget - spentThisMonth)
        budgetProgress = monthlyBudget > 0 ? min(1.0, spentThisMonth / monthlyBudget) : 0

        var categoryMap: [String: Double] = [:]
        for t in monthTransactions where t.type == .expense {
            categoryMap[t.category, default: 0] += t.amount
        }

        categorySpending = Category.commonCategories.compactMap { cat in
            guard let spent = categoryMap[cat.name], spent > 0 else { return nil }
            let budget = budgetRepository.fetchBudget(for: .monthly, category: cat.name)?.amount ?? 0
            return CategorySpending(
                category: cat.name,
                icon: cat.icon,
                color: cat.color,
                spent: spent,
                budget: budget
            )
        }.sorted { $0.spent > $1.spent }
    }
}
