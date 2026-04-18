import Foundation

struct BudgetAllocation: Identifiable {
    let id = UUID()
    let category: String
    var allocated: Double
    var spent: Double
    var remaining: Double {
        allocated - spent
    }
    var percentage: Double {
        guard allocated > 0 else { return 0 }
        return (spent / allocated) * 100
    }
    var isOverBudget: Bool {
        spent > allocated
    }
    
    init(category: String, allocated: Double, spent: Double) {
        self.category = category
        self.allocated = allocated
        self.spent = spent
    }
}

struct AgeOfMoney: Equatable {
    let days: Int
    let trend: AgeOfMoneyTrend
    
    enum AgeOfMoneyTrend {
        case increasing
        case stable
        case decreasing
    }
    
    var displayText: String {
        "\(days) days"
    }
    
    var description: String {
        switch trend {
        case .increasing:
            return "Your money is staying in your account longer. Great job!"
        case .stable:
            return "Your spending pattern is consistent."
        case .decreasing:
            return "Consider reducing expenses to increase your buffer."
        }
    }
    
    var icon: String {
        switch trend {
        case .increasing: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .decreasing: return "arrow.down.right"
        }
    }
    
    var color: String {
        switch trend {
        case .increasing: return "27AE60"
        case .stable: return "F39C12"
        case .decreasing: return "E74C3C"
        }
    }
}
