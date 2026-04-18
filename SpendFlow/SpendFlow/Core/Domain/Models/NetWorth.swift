import Foundation

struct NetWorthEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var assets: [AssetItem]
    var liabilities: [LiabilityItem]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        assets: [AssetItem] = [],
        liabilities: [LiabilityItem] = []
    ) {
        self.id = id
        self.date = date
        self.assets = assets
        self.liabilities = liabilities
    }
    
    var totalAssets: Double {
        assets.map { $0.amount }.reduce(0, +)
    }
    
    var totalLiabilities: Double {
        liabilities.map { $0.amount }.reduce(0, +)
    }
    
    var netWorth: Double {
        totalAssets - totalLiabilities
    }
}

struct AssetItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: AssetCategory
    var amount: Double
    
    init(id: UUID = UUID(), name: String, category: AssetCategory, amount: Double) {
        self.id = id
        self.name = name
        self.category = category
        self.amount = amount
    }
}

struct LiabilityItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: LiabilityCategory
    var amount: Double
    
    init(id: UUID = UUID(), name: String, category: LiabilityCategory, amount: Double) {
        self.id = id
        self.name = name
        self.category = category
        self.amount = amount
    }
}

enum AssetCategory: String, Codable, CaseIterable {
    case checking = "Checking Accounts"
    case savings = "Savings Accounts"
    case investment = "Investments"
    case retirement = "Retirement Accounts"
    case realEstate = "Real Estate"
    case vehicle = "Vehicles"
    case other = "Other Assets"
    
    var icon: String {
        switch self {
        case .checking: return "banknote"
        case .savings: return "piggybank"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .retirement: return "building.columns"
        case .realEstate: return "house.fill"
        case .vehicle: return "car.fill"
        case .other: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .checking: return "007AFF"
        case .savings: return "34C759"
        case .investment: return "5856D6"
        case .retirement: return "FF9500"
        case .realEstate: return "FF2D55"
        case .vehicle: return "5AC8FA"
        case .other: return "8E8E93"
        }
    }
}

enum LiabilityCategory: String, Codable, CaseIterable {
    case mortgage = "Mortgage"
    case studentLoan = "Student Loans"
    case carLoan = "Car Loans"
    case creditCard = "Credit Card Debt"
    case personalLoan = "Personal Loans"
    case medicalDebt = "Medical Debt"
    case other = "Other Liabilities"
    
    var icon: String {
        switch self {
        case .mortgage: return "house.fill"
        case .studentLoan: return "graduationcap.fill"
        case .carLoan: return "car.fill"
        case .creditCard: return "creditcard.fill"
        case .personalLoan: return "hand.raised.fill"
        case .medicalDebt: return "cross.case.fill"
        case .other: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .mortgage: return "E74C3C"
        case .studentLoan: return "F39C12"
        case .carLoan: return "9B59B6"
        case .creditCard: return "E74C3C"
        case .personalLoan: return "FF6B6B"
        case .medicalDebt: return "FF3B30"
        case .other: return "8E8E93"
        }
    }
}
