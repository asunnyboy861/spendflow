import Foundation

class RuleBasedSuggester {
    
    private let keywordMap: [String: (String, Double)]
    
    init() {
        self.keywordMap = [
            "grocery": ("Food & Dining", 0.85),
            "groceries": ("Food & Dining", 0.85),
            "restaurant": ("Food & Dining", 0.90),
            "cafe": ("Food & Dining", 0.85),
            "coffee": ("Food & Dining", 0.80),
            "food": ("Food & Dining", 0.75),
            "dining": ("Food & Dining", 0.85),
            "pizza": ("Food & Dining", 0.90),
            "mcdonalds": ("Food & Dining", 0.95),
            "starbucks": ("Food & Dining", 0.95),
            "chipotle": ("Food & Dining", 0.95),
            
            "uber": ("Transportation", 0.90),
            "lyft": ("Transportation", 0.90),
            "gas": ("Transportation", 0.85),
            "parking": ("Transportation", 0.80),
            "transit": ("Transportation", 0.85),
            "bus": ("Transportation", 0.85),
            "train": ("Transportation", 0.85),
            "metro": ("Transportation", 0.85),
            "fuel": ("Transportation", 0.85),
            "shell": ("Transportation", 0.90),
            "chevron": ("Transportation", 0.90),
            
            "amazon": ("Shopping", 0.80),
            "walmart": ("Shopping", 0.75),
            "target": ("Shopping", 0.75),
            "store": ("Shopping", 0.70),
            "shop": ("Shopping", 0.70),
            "mall": ("Shopping", 0.75),
            "costco": ("Shopping", 0.80),
            "bestbuy": ("Shopping", 0.80),
            
            "netflix": ("Entertainment", 0.95),
            "spotify": ("Entertainment", 0.95),
            "movie": ("Entertainment", 0.85),
            "game": ("Entertainment", 0.80),
            "theater": ("Entertainment", 0.85),
            "cinema": ("Entertainment", 0.85),
            "hulu": ("Entertainment", 0.95),
            "disney": ("Entertainment", 0.95),
            "hbo": ("Entertainment", 0.95),
            
            "pharmacy": ("Health", 0.85),
            "doctor": ("Health", 0.90),
            "hospital": ("Health", 0.90),
            "medical": ("Health", 0.85),
            "health": ("Health", 0.80),
            "dental": ("Health", 0.90),
            "cvs": ("Health", 0.90),
            "walgreens": ("Health", 0.90),
            
            "education": ("Education", 0.85),
            "school": ("Education", 0.85),
            "university": ("Education", 0.90),
            "college": ("Education", 0.90),
            "course": ("Education", 0.80),
            "book": ("Education", 0.75),
            
            "electric": ("Bills & Utilities", 0.90),
            "water": ("Bills & Utilities", 0.90),
            "internet": ("Bills & Utilities", 0.90),
            "phone": ("Bills & Utilities", 0.85),
            "utility": ("Bills & Utilities", 0.90),
            "bill": ("Bills & Utilities", 0.75),
            "at&t": ("Bills & Utilities", 0.90),
            "verizon": ("Bills & Utilities", 0.90),
            
            "salon": ("Other", 0.70),
            "spa": ("Other", 0.70),
            "haircut": ("Other", 0.75),
            "gym": ("Other", 0.70),
            "fitness": ("Other", 0.70),
            
            "subscription": ("Subscription", 0.85),
            "apple": ("Subscription", 0.80),
            "google": ("Subscription", 0.80),
            
            "salary": ("Salary", 0.95),
            "payroll": ("Salary", 0.95),
            "wage": ("Salary", 0.90),
            "freelance": ("Freelance", 0.90),
            "contract": ("Freelance", 0.85),
            "dividend": ("Investment", 0.90),
            "investment": ("Investment", 0.85)
        ]
    }
    
    func suggestCategories(for description: String, amount: Double, limit: Int) -> [CategorySuggestion] {
        var suggestions: [CategorySuggestion] = []
        let lowercased = description.lowercased()
        
        for (keyword, (categoryName, confidence)) in keywordMap {
            if lowercased.contains(keyword) {
                if let category = findCategory(named: categoryName) {
                    suggestions.append(CategorySuggestion(
                        category: category,
                        confidence: confidence,
                        source: .rule
                    ))
                }
            }
        }
        
        return Array(suggestions.sorted { $0.confidence > $1.confidence }.prefix(limit))
    }
    
    private func findCategory(named name: String) -> Category? {
        Category.commonCategories.first { $0.name == name }
            ?? Category.incomeCategories.first { $0.name == name }
    }
}
