import Foundation

struct CategorySuggestion: Identifiable {
    let id = UUID()
    let category: Category
    let confidence: Double
    let source: SuggestionSource
    
    init(category: Category, confidence: Double, source: SuggestionSource) {
        self.category = category
        self.confidence = confidence
        self.source = source
    }
}

enum SuggestionSource {
    case rule
    case history
    case machineLearning
    case defaultCategory
    
    var displayName: String {
        switch self {
        case .rule: return "Rule-based"
        case .history: return "From history"
        case .machineLearning: return "AI suggestion"
        case .defaultCategory: return "Default"
        }
    }
}
