import Combine
import Foundation

class FinancialHealthViewModel: ObservableObject {
    @Published var healthScore: FinancialHealthScore?
    @Published var isLoading: Bool = false
    
    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private let netWorthRepository: NetWorthRepository
    private let calculator: FinancialHealthCalculator
    
    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository,
        netWorthRepository: NetWorthRepository = NetWorthRepository(),
        calculator: FinancialHealthCalculator = FinancialHealthCalculator()
    ) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
        self.netWorthRepository = netWorthRepository
        self.calculator = calculator
        calculateScore()
    }
    
    func calculateScore() {
        let transactions = transactionRepository.fetchAll()
        let budgets = budgetRepository.fetchAll()
        let netWorth = netWorthRepository.fetchLatest()
        
        healthScore = calculator.calculate(
            transactions: transactions,
            budgets: budgets,
            netWorth: netWorth
        )
    }
}
