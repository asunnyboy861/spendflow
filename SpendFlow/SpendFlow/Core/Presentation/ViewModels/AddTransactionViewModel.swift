import Combine
import Foundation

class AddTransactionViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var selectedCategory: Category = .commonCategories[0]
    @Published var note: String = ""
    @Published var transactionType: TransactionType = .expense
    @Published var categories: [Category] = Category.commonCategories
    @Published var suggestedCategory: Category?
    @Published var showSuggestion: Bool = false
    
    private let transactionRepository: TransactionRepository
    private let suggestionService: CategorySuggestionService
    private var cancellables = Set<AnyCancellable>()

    init(
        transactionRepository: TransactionRepository,
        suggestionService: CategorySuggestionService
    ) {
        self.transactionRepository = transactionRepository
        self.suggestionService = suggestionService
        
        setupBindings()
    }
    
    private func setupBindings() {
        $note
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] note in
                self?.getCategorySuggestion(for: note)
            }
            .store(in: &cancellables)
    }
    
    private func getCategorySuggestion(for description: String) {
        guard !description.isEmpty,
              let amountValue = Double(amount),
              amountValue > 0 else {
            suggestedCategory = nil
            showSuggestion = false
            return
        }
        
        let suggestion = suggestionService.suggestCategory(for: description, amount: amountValue)
        
        if suggestion.confidence > 0.7 {
            suggestedCategory = suggestion.category
            showSuggestion = true
        } else {
            suggestedCategory = nil
            showSuggestion = false
        }
    }
    
    func acceptSuggestion() {
        if let suggested = suggestedCategory {
            selectedCategory = suggested
            showSuggestion = false
            HapticFeedback.success()
        }
    }
    
    func dismissSuggestion() {
        showSuggestion = false
    }

    func switchType(_ type: TransactionType) {
        transactionType = type
        categories = type == .expense ? Category.commonCategories : Category.incomeCategories
        selectedCategory = categories[0]
        HapticFeedback.selection()
    }

    func save() -> Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }

        let transaction = Transaction(
            amount: amountValue,
            category: selectedCategory.name,
            date: Date(),
            note: note.isEmpty ? nil : note,
            type: transactionType
        )

        do {
            try transactionRepository.save(transaction)
            HapticFeedback.success()
            return true
        } catch {
            HapticFeedback.error()
            return false
        }
    }

    func reset() {
        amount = ""
        note = ""
        transactionType = .expense
        categories = Category.commonCategories
        selectedCategory = categories[0]
    }
}
