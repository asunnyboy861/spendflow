import Foundation

protocol CategorySuggestionService {
    func suggestCategory(for description: String, amount: Double) -> CategorySuggestion
    func suggestCategories(for description: String, amount: Double, limit: Int) -> [CategorySuggestion]
    func learnFromAdjustment(original: CategorySuggestion, corrected: Category)
}

class CompositeCategorySuggestionService: CategorySuggestionService {
    
    private let ruleBasedSuggester: RuleBasedSuggester
    private let learningService: CategoryLearningService
    
    init(
        ruleBasedSuggester: RuleBasedSuggester,
        learningService: CategoryLearningService
    ) {
        self.ruleBasedSuggester = ruleBasedSuggester
        self.learningService = learningService
    }
    
    func suggestCategory(for description: String, amount: Double) -> CategorySuggestion {
        if let learned = learningService.getSuggestion(for: description) {
            return learned
        }
        
        let ruleSuggestions = ruleBasedSuggester.suggestCategories(for: description, amount: amount, limit: 1)
        if let suggestion = ruleSuggestions.first {
            return suggestion
        }
        
        return CategorySuggestion(
            category: Category.commonCategories.last!,
            confidence: 0.3,
            source: .defaultCategory
        )
    }
    
    func suggestCategories(for description: String, amount: Double, limit: Int) -> [CategorySuggestion] {
        var suggestions: [CategorySuggestion] = []
        
        if let learned = learningService.getSuggestion(for: description) {
            suggestions.append(learned)
        }
        
        let ruleSuggestions = ruleBasedSuggester.suggestCategories(for: description, amount: amount, limit: limit)
        suggestions.append(contentsOf: ruleSuggestions)
        
        let uniqueSuggestions = Dictionary(grouping: suggestions, by: { $0.category.id })
            .values
            .compactMap { $0.first }
            .sorted { $0.confidence > $1.confidence }
        
        return Array(uniqueSuggestions.prefix(limit))
    }
    
    func learnFromAdjustment(original: CategorySuggestion, corrected: Category) {
        learningService.learn(
            category: corrected,
            for: original.category.name
        )
    }
}
