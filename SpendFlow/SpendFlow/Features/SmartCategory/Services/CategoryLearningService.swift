import Foundation

class CategoryLearningService {
    
    private let userDefaults = UserDefaults.standard
    private let learningKey = "com.spendflow.categoryLearning"
    
    private var learnedCategories: [String: Category] {
        get {
            guard let data = userDefaults.data(forKey: learningKey),
                  let decoded = try? JSONDecoder().decode([String: Category].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            userDefaults.set(encoded, forKey: learningKey)
        }
    }
    
    func getSuggestion(for description: String) -> CategorySuggestion? {
        let lowercased = description.lowercased()
        
        for (keyword, category) in learnedCategories {
            if lowercased.contains(keyword) {
                return CategorySuggestion(
                    category: category,
                    confidence: 0.95,
                    source: .history
                )
            }
        }
        
        return nil
    }
    
    func learn(category: Category, for keyword: String) {
        var learned = learnedCategories
        learned[keyword.lowercased()] = category
        learnedCategories = learned
    }
    
    func clearLearning() {
        userDefaults.removeObject(forKey: learningKey)
    }
    
    func getLearnedKeywords() -> [String] {
        return Array(learnedCategories.keys)
    }
}
