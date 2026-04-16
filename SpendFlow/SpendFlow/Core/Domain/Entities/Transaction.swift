import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case expense
    case income
}

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    var amount: Double
    var category: String
    var date: Date
    var note: String?
    var accountID: UUID?
    var type: TransactionType
    var isRecurring: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        date: Date = Date(),
        note: String? = nil,
        accountID: UUID? = nil,
        type: TransactionType,
        isRecurring: Bool = false
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.accountID = accountID
        self.type = type
        self.isRecurring = isRecurring
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
