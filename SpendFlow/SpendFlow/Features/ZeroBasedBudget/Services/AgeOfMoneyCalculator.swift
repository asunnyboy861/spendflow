import Foundation

class AgeOfMoneyCalculator {
    
    func calculate(from transactions: [Transaction]) -> AgeOfMoney? {
        let sortedIncome = transactions
            .filter { $0.type == .income }
            .sorted { $0.date < $1.date }
        
        let sortedExpenses = transactions
            .filter { $0.type == .expense }
            .sorted { $0.date < $1.date }
        
        guard !sortedIncome.isEmpty else { return nil }
        
        var incomeQueue: [(amount: Double, date: Date)] = []
        for income in sortedIncome {
            incomeQueue.append((amount: income.amount, date: income.date))
        }
        
        var totalDays = 0
        var countedTransactions = 0
        
        for expense in sortedExpenses {
            var remainingExpense = expense.amount
            
            while remainingExpense > 0, !incomeQueue.isEmpty {
                let oldestIncome = incomeQueue[0]
                let daysBetween = Calendar.current.dateComponents([.day], from: oldestIncome.date, to: expense.date).day ?? 0
                
                if oldestIncome.amount <= remainingExpense {
                    remainingExpense -= oldestIncome.amount
                    totalDays += max(0, daysBetween)
                    countedTransactions += 1
                    incomeQueue.removeFirst()
                } else {
                    let fraction = remainingExpense / oldestIncome.amount
                    totalDays += Int(Double(max(0, daysBetween)) * fraction)
                    countedTransactions += 1
                    incomeQueue[0].amount -= remainingExpense
                    remainingExpense = 0
                }
            }
        }
        
        guard countedTransactions > 0 else { return nil }
        
        let averageDays = totalDays / countedTransactions
        
        let trend = determineTrend(from: transactions, currentAge: averageDays)
        
        return AgeOfMoney(days: averageDays, trend: trend)
    }
    
    private func determineTrend(from transactions: [Transaction], currentAge: Int) -> AgeOfMoney.AgeOfMoneyTrend {
        let calendar = Calendar.current
        let now = Date()
        
        guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now),
              let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) else {
            return .stable
        }
        
        let recentTransactions = transactions.filter { $0.date >= threeMonthsAgo }
        let olderTransactions = transactions.filter { $0.date >= sixMonthsAgo && $0.date < threeMonthsAgo }
        
        let recentAge = calculateSimpleAge(from: recentTransactions)
        let olderAge = calculateSimpleAge(from: olderTransactions)
        
        if recentAge > olderAge + 3 {
            return .increasing
        } else if recentAge < olderAge - 3 {
            return .decreasing
        } else {
            return .stable
        }
    }
    
    private func calculateSimpleAge(from transactions: [Transaction]) -> Int {
        let income = transactions.filter { $0.type == .income }.map { $0.amount }.reduce(0, +)
        let expenses = transactions.filter { $0.type == .expense }.map { $0.amount }.reduce(0, +)
        
        guard income > 0 else { return 0 }
        
        let dailyExpense = expenses / Double(max(1, Calendar.current.dateComponents([.day], from: transactions.first?.date ?? Date(), to: transactions.last?.date ?? Date()).day ?? 1))
        
        guard dailyExpense > 0 else { return 30 }
        
        return Int(income / dailyExpense)
    }
}
