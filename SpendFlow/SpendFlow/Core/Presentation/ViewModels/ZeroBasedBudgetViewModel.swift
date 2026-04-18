import Combine
import Foundation

class ZeroBasedBudgetViewModel: ObservableObject {
    @Published var allocations: [BudgetAllocation] = []
    @Published var totalIncome: Double = 0
    @Published var totalAllocated: Double = 0
    @Published var totalUnallocated: Double = 0
    @Published var ageOfMoney: AgeOfMoney?
    @Published var isLoading: Bool = false
    
    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private let ageOfMoneyCalculator: AgeOfMoneyCalculator
    private var cancellables = Set<AnyCancellable>()
    
    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository,
        ageOfMoneyCalculator: AgeOfMoneyCalculator
    ) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
        self.ageOfMoneyCalculator = ageOfMoneyCalculator
        
        loadData()
    }
    
    func loadData() {
        Task {
            await MainActor.run {
                self.isLoading = true
            }
            
            let transactions = transactionRepository.fetchAll()
            let budgets = budgetRepository.fetchAll()
            
            let calendar = Calendar.current
            let now = Date()
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            
            let monthTransactions = transactions.filter { $0.date >= startOfMonth }
            
            let income = monthTransactions
                .filter { $0.type == .income }
                .map { $0.amount }
                .reduce(0, +)
            
            let allocations = budgets.compactMap { budget -> BudgetAllocation? in
                guard let category = budget.category else { return nil }
                let spent = monthTransactions
                    .filter { $0.category == category && $0.type == .expense }
                    .map { $0.amount }
                    .reduce(0, +)
                
                return BudgetAllocation(
                    category: category,
                    allocated: budget.amount,
                    spent: spent
                )
            }
            
            let totalAllocated = allocations.map { $0.allocated }.reduce(0, +)
            let ageOfMoney = ageOfMoneyCalculator.calculate(from: transactions)
            
            await MainActor.run {
                self.totalIncome = income
                self.allocations = allocations
                self.totalAllocated = totalAllocated
                self.totalUnallocated = income - totalAllocated
                self.ageOfMoney = ageOfMoney
                self.isLoading = false
            }
        }
    }
    
    func allocateIncome(amount: Double, to category: String) {
        Task {
            let budgets = budgetRepository.fetchAll()
            if let budget = budgets.first(where: { $0.category == category }) {
                var updatedBudget = budget
                updatedBudget.amount += amount
                try budgetRepository.update(updatedBudget)
                loadData()
            }
        }
    }
    
    func transferBudget(from fromCategory: String, to toCategory: String, amount: Double) {
        Task {
            let budgets = budgetRepository.fetchAll()
            
            guard let fromBudget = budgets.first(where: { $0.category == fromCategory }),
                  let toBudget = budgets.first(where: { $0.category == toCategory }) else { return }
            
            var updatedFromBudget = fromBudget
            updatedFromBudget.amount -= amount
            try budgetRepository.update(updatedFromBudget)
            
            var updatedToBudget = toBudget
            updatedToBudget.amount += amount
            try budgetRepository.update(updatedToBudget)
            
            loadData()
        }
    }
}
