import Combine
import Foundation

class AddTransactionViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var selectedCategory: Category = .commonCategories[0]
    @Published var note: String = ""
    @Published var transactionType: TransactionType = .expense
    @Published var categories: [Category] = Category.commonCategories

    private let transactionRepository: TransactionRepository

    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
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
