import Combine
import Foundation

class InsightsViewModel: ObservableObject {
    @Published var categorySpending: [CategorySpending] = []
    @Published var monthlyData: [MonthlyData] = []
    @Published var budgetComparison: [BudgetComparison] = []
    @Published var isLoading: Bool = false
    @Published var selectedPeriod: TimePeriod = .thisMonth
    
    let transactionRepository: TransactionRepository
    let budgetRepository: BudgetRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
        
        loadData()
    }
    
    func loadData() {
        Task {
            await MainActor.run {
                self.isLoading = true
            }
            
            let transactions = transactionRepository.fetchAll()
            let budgets = budgetRepository.fetchAll()
            
            let filteredTransactions = filterTransactionsByPeriod(transactions)
            
            let categorySpending = calculateCategorySpending(filteredTransactions)
            let monthlyData = calculateMonthlyTrend(transactions)
            let budgetComparison = calculateBudgetComparison(filteredTransactions, budgets)
            
            await MainActor.run {
                self.categorySpending = categorySpending
                self.monthlyData = monthlyData
                self.budgetComparison = budgetComparison
                self.isLoading = false
            }
        }
    }
    
    private func filterTransactionsByPeriod(_ transactions: [Transaction]) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return transactions.filter { $0.date >= startOfWeek }
            
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return transactions.filter { $0.date >= startOfMonth }
            
        case .last3Months:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!
            return transactions.filter { $0.date >= threeMonthsAgo }
            
        case .thisYear:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return transactions.filter { $0.date >= startOfYear }
        }
    }
    
    private func calculateCategorySpending(_ transactions: [Transaction]) -> [CategorySpending] {
        let expenses = transactions.filter { $0.type == .expense }
        let totalAmount = expenses.map { $0.amount }.reduce(0, +)
        
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
        
        let spending = grouped.map { (category, transactions) in
            let amount = transactions.map { $0.amount }.reduce(0, +)
            let percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0
            let color = CategoryColorProvider.color(for: category)
            
            return CategorySpending(
                categoryName: category,
                amount: amount,
                percentage: percentage,
                color: color,
                transactionCount: transactions.count
            )
        }
        
        return spending.sorted { $0.amount > $1.amount }
    }
    
    private func calculateMonthlyTrend(_ transactions: [Transaction]) -> [MonthlyData] {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [MonthlyData] = []
        
        for i in 0..<6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            
            let monthTransactions = transactions.filter { 
                $0.date >= startOfMonth && $0.date < endOfMonth 
            }
            
            let income = monthTransactions
                .filter { $0.type == .income }
                .map { $0.amount }
                .reduce(0, +)
            
            let expense = monthTransactions
                .filter { $0.type == .expense }
                .map { $0.amount }
                .reduce(0, +)
            
            let savings = income - expense
            
            monthlyData.append(MonthlyData(
                month: startOfMonth,
                income: income,
                expense: expense,
                savings: savings
            ))
        }
        
        return monthlyData.reversed()
    }
    
    private func calculateBudgetComparison(_ transactions: [Transaction], _ budgets: [Budget]) -> [BudgetComparison] {
        return budgets.map { budget in
            let spent = transactions
                .filter { $0.category == budget.category ?? "General" && $0.type == .expense }
                .map { $0.amount }
                .reduce(0, +)
            
            return BudgetComparison(
                categoryName: budget.category ?? "General",
                budgeted: budget.amount,
                spent: spent
            )
        }
    }
    
    func changePeriod(_ period: TimePeriod) {
        selectedPeriod = period
        loadData()
    }
}

enum TimePeriod: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case last3Months = "Last 3 Months"
    case thisYear = "This Year"
}

private struct CategoryColorProvider {
    static func color(for category: String) -> String {
        let colorMap: [String: String] = [
            "Food & Dining": "FF6B6B",
            "Transportation": "4ECDC4",
            "Shopping": "45B7D1",
            "Entertainment": "96CEB4",
            "Healthcare": "FFEAA7",
            "Education": "DDA0DD",
            "Bills & Utilities": "F39C12",
            "Personal Care": "E74C3C",
            "Subscription": "9B59B6",
            "Other": "95A5A6",
            "Salary": "27AE60",
            "Freelance": "2ECC71",
            "Investment": "1ABC9C"
        ]
        
        return colorMap[category] ?? "95A5A6"
    }
}
