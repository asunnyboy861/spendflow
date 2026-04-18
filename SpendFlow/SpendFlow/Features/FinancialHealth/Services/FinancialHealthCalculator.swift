import Foundation

class FinancialHealthCalculator {
    
    func calculate(
        transactions: [Transaction],
        budgets: [Budget],
        netWorth: NetWorthEntry?
    ) -> FinancialHealthScore {
        let dimensions = [
            calculateBudgetAdherence(transactions: transactions, budgets: budgets),
            calculateSavingsRate(transactions: transactions),
            calculateSpendingConsistency(transactions: transactions),
            calculateDebtManagement(netWorth: netWorth),
            calculateEmergencyReadiness(transactions: transactions, netWorth: netWorth)
        ]
        
        let totalScore = dimensions.map { $0.score }.reduce(0, +)
        let grade = FinancialGrade(score: totalScore)
        
        return FinancialHealthScore(
            overallScore: totalScore,
            grade: grade,
            dimensions: dimensions,
            date: Date()
        )
    }
    
    private func calculateBudgetAdherence(transactions: [Transaction], budgets: [Budget]) -> HealthDimension {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        let monthExpenses = transactions.filter { $0.date >= startOfMonth && $0.type == .expense }
        let totalBudget = budgets.map { $0.amount }.reduce(0, +)
        let totalSpent = monthExpenses.map { $0.amount }.reduce(0, +)
        
        var score = 20
        if totalBudget > 0 {
            let ratio = totalSpent / totalBudget
            if ratio <= 0.8 {
                score = 20
            } else if ratio <= 0.9 {
                score = 17
            } else if ratio <= 1.0 {
                score = 14
            } else if ratio <= 1.1 {
                score = 10
            } else {
                score = 5
            }
        }
        
        return HealthDimension(
            name: "Budget Adherence",
            icon: "target",
            score: score,
            maxScore: 20,
            color: "007AFF",
            tips: score < 15 ? [
                "Review your spending categories regularly",
                "Set realistic budget limits",
                "Use the zero-based budget method"
            ] : ["You're staying within your budget!"]
        )
    }
    
    private func calculateSavingsRate(transactions: [Transaction]) -> HealthDimension {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        let monthTransactions = transactions.filter { $0.date >= startOfMonth }
        let income = monthTransactions.filter { $0.type == .income }.map { $0.amount }.reduce(0, +)
        let expenses = monthTransactions.filter { $0.type == .expense }.map { $0.amount }.reduce(0, +)
        
        let savingsRate = income > 0 ? (income - expenses) / income : 0
        
        var score: Int
        if savingsRate >= 0.3 {
            score = 20
        } else if savingsRate >= 0.2 {
            score = 17
        } else if savingsRate >= 0.1 {
            score = 14
        } else if savingsRate >= 0.05 {
            score = 10
        } else if savingsRate > 0 {
            score = 7
        } else {
            score = 3
        }
        
        return HealthDimension(
            name: "Savings Rate",
            icon: "piggybank",
            score: score,
            maxScore: 20,
            color: "34C759",
            tips: score < 14 ? [
                "Aim to save at least 20% of your income",
                "Automate your savings with direct deposit",
                "Follow the 50/30/20 rule"
            ] : ["Your savings rate is healthy!"]
        )
    }
    
    private func calculateSpendingConsistency(transactions: [Transaction]) -> HealthDimension {
        let calendar = Calendar.current
        let now = Date()
        
        var monthlySpending: [Double] = []
        for i in 0..<3 {
            guard let monthStart = calendar.date(byAdding: .month, value: -i, to: now),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { continue }
            
            let monthExpenses = transactions.filter { $0.date >= monthStart && $0.date < monthEnd && $0.type == .expense }
            monthlySpending.append(monthExpenses.map { $0.amount }.reduce(0, +))
        }
        
        guard monthlySpending.count >= 2 else {
            return HealthDimension(
                name: "Spending Consistency",
                icon: "chart.line.flattrend.xyaxis",
                score: 10,
                maxScore: 20,
                color: "5856D6",
                tips: ["Add more transactions to get a consistency score"]
            )
        }
        
        let avg = monthlySpending.reduce(0, +) / Double(monthlySpending.count)
        let variance = monthlySpending.map { pow($0 - avg, 2) }.reduce(0, +) / Double(monthlySpending.count)
        let stdDev = sqrt(variance)
        let cv = avg > 0 ? stdDev / avg : 1.0
        
        var score: Int
        if cv <= 0.1 {
            score = 20
        } else if cv <= 0.2 {
            score = 17
        } else if cv <= 0.3 {
            score = 14
        } else if cv <= 0.5 {
            score = 10
        } else {
            score = 5
        }
        
        return HealthDimension(
            name: "Spending Consistency",
            icon: "chart.line.flattrend.xyaxis",
            score: score,
            maxScore: 20,
            color: "5856D6",
            tips: score < 14 ? [
                "Keep your monthly spending consistent",
                "Avoid large impulse purchases",
                "Plan for irregular expenses"
            ] : ["Your spending is consistent!"]
        )
    }
    
    private func calculateDebtManagement(netWorth: NetWorthEntry?) -> HealthDimension {
        guard let entry = netWorth else {
            return HealthDimension(
                name: "Debt Management",
                icon: "creditcard",
                score: 10,
                maxScore: 20,
                color: "FF9500",
                tips: ["Add your net worth data to track debt management"]
            )
        }
        
        let debtToAssetRatio = entry.totalAssets > 0 ? entry.totalLiabilities / entry.totalAssets : 1.0
        
        var score: Int
        if debtToAssetRatio <= 0.1 {
            score = 20
        } else if debtToAssetRatio <= 0.3 {
            score = 17
        } else if debtToAssetRatio <= 0.5 {
            score = 14
        } else if debtToAssetRatio <= 0.7 {
            score = 10
        } else {
            score = 5
        }
        
        return HealthDimension(
            name: "Debt Management",
            icon: "creditcard",
            score: score,
            maxScore: 20,
            color: "FF9500",
            tips: score < 14 ? [
                "Pay more than the minimum on credit cards",
                "Consider the debt avalanche method",
                "Avoid taking on new debt"
            ] : ["Your debt levels are manageable!"]
        )
    }
    
    private func calculateEmergencyReadiness(transactions: [Transaction], netWorth: NetWorthEntry?) -> HealthDimension {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        let monthExpenses = transactions.filter { $0.date >= startOfMonth && $0.type == .expense }
        let monthlyExpense = monthExpenses.map { $0.amount }.reduce(0, +)
        
        let liquidAssets = netWorth?.assets.filter {
            $0.category == .checking || $0.category == .savings
        }.map { $0.amount }.reduce(0, +) ?? 0
        
        let monthsCovered = monthlyExpense > 0 ? liquidAssets / monthlyExpense : 0
        
        var score: Int
        if monthsCovered >= 6 {
            score = 20
        } else if monthsCovered >= 3 {
            score = 17
        } else if monthsCovered >= 2 {
            score = 14
        } else if monthsCovered >= 1 {
            score = 10
        } else {
            score = 5
        }
        
        return HealthDimension(
            name: "Emergency Fund",
            icon: "shield.fill",
            score: score,
            maxScore: 20,
            color: "FF2D55",
            tips: score < 14 ? [
                "Aim for 3-6 months of expenses in savings",
                "Start with a $1,000 emergency fund",
                "Keep emergency funds in a high-yield savings account"
            ] : ["Your emergency fund is solid!"]
        )
    }
}
