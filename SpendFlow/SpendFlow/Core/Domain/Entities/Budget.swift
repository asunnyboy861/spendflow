import Foundation

enum BudgetPeriod: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
}

struct Budget: Identifiable, Codable, Equatable {
    let id: UUID
    var amount: Double
    var period: BudgetPeriod
    var startDate: Date
    var category: String?
    var isActive: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        period: BudgetPeriod,
        startDate: Date = Date(),
        category: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.amount = amount
        self.period = period
        self.startDate = startDate
        self.category = category
        self.isActive = isActive
        self.createdAt = Date()
    }
}
