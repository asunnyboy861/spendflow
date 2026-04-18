import Combine
import Foundation

class NetWorthViewModel: ObservableObject {
    @Published var currentEntry: NetWorthEntry?
    @Published var trendEntries: [NetWorthEntry] = []
    @Published var isLoading: Bool = false
    
    private let repository: NetWorthRepository
    
    init(repository: NetWorthRepository) {
        self.repository = repository
        loadData()
    }
    
    func loadData() {
        currentEntry = repository.fetchLatest()
        trendEntries = repository.fetchTrend()
    }
    
    func saveEntry(_ entry: NetWorthEntry) {
        repository.add(entry)
        loadData()
    }
    
    func updateEntry(_ entry: NetWorthEntry) {
        repository.update(entry)
        loadData()
    }
    
    func deleteEntry(_ entryId: UUID) {
        repository.delete(entryId)
        loadData()
    }
    
    var currentNetWorth: Double {
        currentEntry?.netWorth ?? 0
    }
    
    var totalAssets: Double {
        currentEntry?.totalAssets ?? 0
    }
    
    var totalLiabilities: Double {
        currentEntry?.totalLiabilities ?? 0
    }
    
    var netWorthChange: Double {
        guard trendEntries.count >= 2 else { return 0 }
        let latest = trendEntries.last?.netWorth ?? 0
        let previous = trendEntries[trendEntries.count - 2].netWorth
        return latest - previous
    }
    
    var netWorthChangePercentage: Double {
        guard trendEntries.count >= 2 else { return 0 }
        let previous = trendEntries[trendEntries.count - 2].netWorth
        guard previous != 0 else { return 0 }
        return (netWorthChange / abs(previous)) * 100
    }
    
    var netWorthTrend: NetWorthTrend {
        if netWorthChange > 0 {
            return .increasing
        } else if netWorthChange < 0 {
            return .decreasing
        } else {
            return .stable
        }
    }
}

enum NetWorthTrend {
    case increasing
    case stable
    case decreasing
    
    var icon: String {
        switch self {
        case .increasing: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .decreasing: return "arrow.down.right"
        }
    }
    
    var color: String {
        switch self {
        case .increasing: return "27AE60"
        case .stable: return "F39C12"
        case .decreasing: return "E74C3C"
        }
    }
}
