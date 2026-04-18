import Foundation

struct FinancialHealthScore: Identifiable {
    let id = UUID()
    let overallScore: Int
    let grade: FinancialGrade
    let dimensions: [HealthDimension]
    let date: Date
    
    var scoreColor: String {
        switch grade {
        case .excellent: return "27AE60"
        case .good: return "34C759"
        case .fair: return "F39C12"
        case .needsWork: return "E74C3C"
        case .poor: return "FF3B30"
        }
    }
    
    var scoreDescription: String {
        switch grade {
        case .excellent:
            return "Outstanding! You're managing your finances exceptionally well."
        case .good:
            return "Great job! Your finances are in good shape with room for improvement."
        case .fair:
            return "You're doing okay, but there are areas that need attention."
        case .needsWork:
            return "Your finances need some work. Focus on the areas below."
        case .poor:
            return "Urgent attention needed. Consider seeking financial guidance."
        }
    }
}

enum FinancialGrade: String, CaseIterable {
    case excellent = "A"
    case good = "B"
    case fair = "C"
    case needsWork = "D"
    case poor = "F"
    
    init(score: Int) {
        switch score {
        case 90...100: self = .excellent
        case 75..<90: self = .good
        case 55..<75: self = .fair
        case 35..<55: self = .needsWork
        default: self = .poor
        }
    }
}

struct HealthDimension: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let score: Int
    let maxScore: Int
    let color: String
    let tips: [String]
    
    var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return Double(score) / Double(maxScore) * 100
    }
    
    var grade: String {
        switch percentage {
        case 90...100: return "A"
        case 75..<90: return "B"
        case 55..<75: return "C"
        case 35..<55: return "D"
        default: return "F"
        }
    }
}
