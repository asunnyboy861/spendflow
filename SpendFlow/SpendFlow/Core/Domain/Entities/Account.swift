import Foundation

enum AccountType: String, Codable, CaseIterable {
    case bank
    case credit
    case cash
}

struct Account: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: AccountType
    var balance: Double
    var institution: String?
    var color: String
    var icon: String
    var isActive: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        balance: Double = 0,
        institution: String? = nil,
        color: String = "007AFF",
        icon: String = "banknote",
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.institution = institution
        self.color = color
        self.icon = icon
        self.isActive = isActive
        self.createdAt = Date()
    }
}
