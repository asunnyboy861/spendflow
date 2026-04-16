import Combine
import CoreData

class TransactionRepositoryImpl: TransactionRepository {
    private let coreDataStack: CoreDataStack
    private let subject = CurrentValueSubject<[Transaction], Never>([])

    var transactionsPublisher: AnyPublisher<[Transaction], Never> {
        subject.eraseToAnyPublisher()
    }

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        refresh()
    }

    private func makeRequest() -> NSFetchRequest<TransactionCD> {
        TransactionCD.fetchRequest() as! NSFetchRequest<TransactionCD>
    }

    func fetchAll() -> [Transaction] {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionCD.date, ascending: false)]

        do {
            let results = try context.fetch(request)
            let transactions = results.map { $0.toDomain() }
            subject.send(transactions)
            return transactions
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchTransactions(from startDate: Date, to endDate: Date) -> [Transaction] {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionCD.date, ascending: false)]

        do {
            return try context.fetch(request).map { $0.toDomain() }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchTransactions(forAccount accountID: UUID) -> [Transaction] {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "accountID == %@", accountID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionCD.date, ascending: false)]

        do {
            return try context.fetch(request).map { $0.toDomain() }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchTransactions(forCategory category: String) -> [Transaction] {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionCD.date, ascending: false)]

        do {
            return try context.fetch(request).map { $0.toDomain() }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func save(_ transaction: Transaction) throws {
        let context = coreDataStack.viewContext
        TransactionCD.fromDomain(transaction, context: context)
        try context.save()
        refresh()
    }

    func update(_ transaction: Transaction) throws {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)

        if let existing = try context.fetch(request).first {
            existing.amount = transaction.amount
            existing.category = transaction.category
            existing.date = transaction.date
            existing.note = transaction.note
            existing.type = transaction.type.rawValue
            existing.isRecurring = transaction.isRecurring
            existing.updatedAt = Date()
            try context.save()
            refresh()
        }
    }

    func delete(_ transaction: Transaction) throws {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)

        if let existing = try context.fetch(request).first {
            context.delete(existing)
            try context.save()
            refresh()
        }
    }

    private func refresh() {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionCD.date, ascending: false)]

        do {
            let results = try context.fetch(request)
            subject.send(results.map { $0.toDomain() })
        } catch {
            print("Refresh error: \(error.localizedDescription)")
        }
    }
}
