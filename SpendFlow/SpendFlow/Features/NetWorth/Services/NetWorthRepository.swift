import Foundation

class NetWorthRepository {
    
    private let defaults = UserDefaults.standard
    private let entriesKey = "net_worth_entries"
    
    func fetchAll() -> [NetWorthEntry] {
        guard let data = defaults.data(forKey: entriesKey) else { return [] }
        do {
            return try JSONDecoder().decode([NetWorthEntry].self, from: data)
        } catch {
            return []
        }
    }
    
    func save(_ entries: [NetWorthEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            defaults.set(data, forKey: entriesKey)
        } catch {}
    }
    
    func add(_ entry: NetWorthEntry) {
        var entries = fetchAll()
        entries.append(entry)
        entries.sort { $0.date < $1.date }
        save(entries)
    }
    
    func update(_ entry: NetWorthEntry) {
        var entries = fetchAll()
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            save(entries)
        }
    }
    
    func delete(_ entryId: UUID) {
        var entries = fetchAll()
        entries.removeAll { $0.id == entryId }
        save(entries)
    }
    
    func fetchLatest() -> NetWorthEntry? {
        fetchAll().last
    }
    
    func fetchTrend(months: Int = 12) -> [NetWorthEntry] {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .month, value: -months, to: Date())!
        return fetchAll().filter { $0.date >= cutoff }
    }
}
