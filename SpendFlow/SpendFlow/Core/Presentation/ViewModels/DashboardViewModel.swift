import Combine
import Foundation

class DashboardViewModel: ObservableObject {
    @Published var remainingToday: Double = 0
    @Published var remainingThisMonth: Double = 0
    @Published var spentToday: Double = 0
    @Published var spentThisMonth: Double = 0
    @Published var budgetProgress: Double = 0
    @Published var recentTransactions: [Transaction] = []
    @Published var totalBalance: Double = 0
    @Published var monthlyBudget: Double = 0

    let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private let accountRepository: AccountRepository
    private var cancellables = Set<AnyCancellable>()

    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository,
        accountRepository: AccountRepository
    ) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
        self.accountRepository = accountRepository

        bindRepositories()
        loadData()
    }

    private func bindRepositories() {
        transactionRepository.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.updateRecentTransactions(transactions)
                self?.recalculateBudgets()
            }
            .store(in: &cancellables)

        budgetRepository.budgetsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recalculateBudgets()
            }
            .store(in: &cancellables)

        accountRepository.accountsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accounts in
                self?.updateTotalBalance(accounts)
            }
            .store(in: &cancellables)
    }

    func loadData() {
        recalculateBudgets()
        let transactions = transactionRepository.fetchAll()
        updateRecentTransactions(transactions)
        updateTotalBalance(accountRepository.fetchActive())
    }

    private func recalculateBudgets() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        let todayExpenses = transactionRepository
            .fetchTransactions(from: today, to: tomorrow)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }

        let monthExpenses = transactionRepository
            .fetchTransactions(from: monthStart, to: monthEnd)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }

        let dailyBudget = budgetRepository.fetchBudget(for: .daily)?.amount ?? 0
        monthlyBudget = budgetRepository.fetchBudget(for: .monthly)?.amount ?? AppConstants.defaultMonthlyBudget

        spentToday = todayExpenses
        remainingToday = max(0, dailyBudget - todayExpenses)
        spentThisMonth = monthExpenses
        remainingThisMonth = max(0, monthlyBudget - monthExpenses)
        budgetProgress = monthlyBudget > 0 ? min(1.0, monthExpenses / monthlyBudget) : 0
    }

    private func updateRecentTransactions(_ transactions: [Transaction]) {
        recentTransactions = Array(transactions.prefix(AppConstants.recentTransactionsLimit))
    }

    private func updateTotalBalance(_ accounts: [Account]) {
        totalBalance = accounts.reduce(0) { total, account in
            switch account.type {
            case .bank, .cash: return total + account.balance
            case .credit: return total - abs(account.balance)
            }
        }
    }
}
