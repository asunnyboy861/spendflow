import Foundation

struct BankAccount: Identifiable, Codable, Equatable {
    let id: UUID
    let plaidAccountId: String
    let bankName: String
    let accountName: String
    let accountType: BankAccountType
    let accountSubtype: String
    var balance: Double
    var currency: String
    var isConnected: Bool
    var lastSyncDate: Date?
    
    init(
        id: UUID = UUID(),
        plaidAccountId: String,
        bankName: String,
        accountName: String,
        accountType: BankAccountType,
        accountSubtype: String,
        balance: Double,
        currency: String = "USD",
        isConnected: Bool = true,
        lastSyncDate: Date? = nil
    ) {
        self.id = id
        self.plaidAccountId = plaidAccountId
        self.bankName = bankName
        self.accountName = accountName
        self.accountType = accountType
        self.accountSubtype = accountSubtype
        self.balance = balance
        self.currency = currency
        self.isConnected = isConnected
        self.lastSyncDate = lastSyncDate
    }
    
    var displayName: String {
        "\(bankName) - \(accountName)"
    }
    
    var icon: String {
        switch accountType {
        case .checking:
            return "banknote"
        case .savings:
            return "piggybank"
        case .credit:
            return "creditcard"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .other:
            return "building.columns"
        }
    }
}

enum BankAccountType: String, Codable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case credit = "Credit Card"
    case investment = "Investment"
    case other = "Other"
    
    var color: String {
        switch self {
        case .checking: return "007AFF"
        case .savings: return "34C759"
        case .credit: return "FF3B30"
        case .investment: return "5856D6"
        case .other: return "8E8E93"
        }
    }
}
