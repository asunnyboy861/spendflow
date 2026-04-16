import Combine
import Foundation

class CalculateRemainingBudget: ObservableObject {
    @Published var remainingToday: Double = 0
    @Published var remainingThisWeek: Double = 0
    @Published var remainingThisMonth: Double = 0

    @Published var spentToday: Double = 0
    @Published var spentThisWeek: Double = 0
    @Published var spentThisMonth: Double = 0

    @Published var budgetProgress: Double = 0

    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private var cancellables = Set<AnyCancellable>()

    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository

        transactionRepository.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recalculateAll()
            }
            .store(in: &cancellables)
    }

    func recalculateAll() {
        calculateRemainingToday()
        calculateRemainingThisWeek()
        calculateRemainingThisMonth()
    }

    func calculateRemainingToday() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let todayExpenses = transactionRepository
            .fetchTransactions(from: today, to: tomorrow)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }

        let dailyBudget = budgetRepository.fetchBudget(for: .daily)?.amount ?? 0

        spentToday = todayExpenses
        remainingToday = max(0, dailyBudget - todayExpenses)
        budgetProgress = dailyBudget > 0 ? min(1.0, todayExpenses / dailyBudget) : 0
    }

    func calculateRemainingThisWeek() {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

        let weekExpenses = transactionRepository
            .fetchTransactions(from: weekStart, to: weekEnd)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }

        let weeklyBudget = budgetRepository.fetchBudget(for: .weekly)?.amount ?? 0

        spentThisWeek = weekExpenses
        remainingThisWeek = max(0, weeklyBudget - weekExpenses)
    }

    func calculateRemainingThisMonth() {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        let monthExpenses = transactionRepository
            .fetchTransactions(from: monthStart, to: monthEnd)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }

        let monthlyBudget = budgetRepository.fetchBudget(for: .monthly)?.amount ?? 0

        spentThisMonth = monthExpenses
        remainingThisMonth = max(0, monthlyBudget - monthExpenses)
    }
}
