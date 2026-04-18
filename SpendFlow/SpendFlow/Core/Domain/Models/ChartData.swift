import Foundation

struct CategorySpending: Identifiable {
    let id = UUID()
    let categoryName: String
    let amount: Double
    let percentage: Double
    let color: String
    let transactionCount: Int
    
    init(
        categoryName: String,
        amount: Double,
        percentage: Double,
        color: String,
        transactionCount: Int
    ) {
        self.categoryName = categoryName
        self.amount = amount
        self.percentage = percentage
        self.color = color
        self.transactionCount = transactionCount
    }
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Date
    let income: Double
    let expense: Double
    let savings: Double
    
    init(month: Date, income: Double, expense: Double, savings: Double) {
        self.month = month
        self.income = income
        self.expense = expense
        self.savings = savings
    }
}

struct BudgetComparison: Identifiable {
    let id = UUID()
    let categoryName: String
    let budgeted: Double
    let spent: Double
    let remaining: Double
    let percentage: Double
    
    init(
        categoryName: String,
        budgeted: Double,
        spent: Double
    ) {
        self.categoryName = categoryName
        self.budgeted = budgeted
        self.spent = spent
        self.remaining = budgeted - spent
        self.percentage = budgeted > 0 ? (spent / budgeted) * 100 : 0
    }
}
