import Foundation

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var budget: Double?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String,
        budget: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.budget = budget
    }

    static let commonCategories: [Category] = [
        Category(name: "Food & Dining", icon: "fork.knife", color: "FF9500"),
        Category(name: "Transportation", icon: "car.fill", color: "5856D6"),
        Category(name: "Shopping", icon: "bag.fill", color: "FF2D55"),
        Category(name: "Bills & Utilities", icon: "doc.text.fill", color: "34C759"),
        Category(name: "Entertainment", icon: "gamecontroller.fill", color: "AF52DE"),
        Category(name: "Health", icon: "heart.fill", color: "FF3B30"),
        Category(name: "Education", icon: "book.fill", color: "007AFF"),
        Category(name: "Travel", icon: "airplane", color: "5AC8FA"),
        Category(name: "Subscription", icon: "repeat", color: "FFD60A"),
        Category(name: "Other", icon: "ellipsis.circle.fill", color: "8E8E93")
    ]

    static let incomeCategories: [Category] = [
        Category(name: "Salary", icon: "banknote.fill", color: "34C759"),
        Category(name: "Freelance", icon: "laptopcomputer", color: "007AFF"),
        Category(name: "Investment", icon: "chart.line.uptrend.xyaxis", color: "5856D6"),
        Category(name: "Gift", icon: "gift.fill", color: "FF2D55"),
        Category(name: "Other Income", icon: "plus.circle.fill", color: "8E8E93")
    ]
}
