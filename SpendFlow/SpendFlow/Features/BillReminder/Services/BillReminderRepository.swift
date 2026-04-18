import Foundation

class BillReminderRepository {
    
    private let defaults = UserDefaults.standard
    private let billsKey = "saved_bills"
    
    func fetchAll() -> [BillReminder] {
        guard let data = defaults.data(forKey: billsKey) else { return [] }
        do {
            return try JSONDecoder().decode([BillReminder].self, from: data)
        } catch {
            return []
        }
    }
    
    func save(_ bills: [BillReminder]) {
        do {
            let data = try JSONEncoder().encode(bills)
            defaults.set(data, forKey: billsKey)
        } catch {}
    }
    
    func add(_ bill: BillReminder) {
        var bills = fetchAll()
        bills.append(bill)
        save(bills)
    }
    
    func update(_ bill: BillReminder) {
        var bills = fetchAll()
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            bills[index] = bill
            save(bills)
        }
    }
    
    func delete(_ billId: UUID) {
        var bills = fetchAll()
        bills.removeAll { $0.id == billId }
        save(bills)
    }
    
    func fetchUpcoming(days: Int = 30) -> [BillReminder] {
        let calendar = Calendar.current
        let now = Date()
        let futureDate = calendar.date(byAdding: .day, value: days, to: now)!
        
        return fetchAll()
            .filter { !$0.isPaid && $0.dueDate >= now && $0.dueDate <= futureDate }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    func fetchOverdue() -> [BillReminder] {
        fetchAll()
            .filter { $0.isOverdue }
            .sorted { $0.dueDate < $1.dueDate }
    }
}
