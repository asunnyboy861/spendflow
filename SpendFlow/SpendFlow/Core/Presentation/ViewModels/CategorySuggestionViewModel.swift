import Combine
import Foundation

class CategorySuggestionViewModel: ObservableObject {
    @Published var suggestions: [CategorySuggestion] = []
    @Published var selectedCategory: Category?
    @Published var isLoading: Bool = false
    
    private let suggestionService: CategorySuggestionService
    private var currentDescription: String = ""
    private var currentAmount: Double = 0
    
    init(suggestionService: CategorySuggestionService) {
        self.suggestionService = suggestionService
    }
    
    func getSuggestions(for description: String, amount: Double) {
        currentDescription = description
        currentAmount = amount
        
        Task {
            await MainActor.run {
                self.isLoading = true
            }
            
            let suggestions = suggestionService.suggestCategories(
                for: description,
                amount: amount,
                limit: 5
            )
            
            await MainActor.run {
                self.suggestions = suggestions
                self.selectedCategory = suggestions.first?.category
                self.isLoading = false
            }
        }
    }
    
    func selectCategory(_ category: Category) {
        selectedCategory = category
        
        if let originalSuggestion = suggestions.first(where: { $0.category.id == category.id }) {
            suggestionService.learnFromAdjustment(
                original: originalSuggestion,
                corrected: category
            )
        }
    }
    
    func getTopSuggestion() -> CategorySuggestion? {
        return suggestions.first
    }
}
