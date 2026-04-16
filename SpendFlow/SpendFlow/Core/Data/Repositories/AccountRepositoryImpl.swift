import Combine
import CoreData

class AccountRepositoryImpl: AccountRepository {
    private let coreDataStack: CoreDataStack
    private let subject = CurrentValueSubject<[Account], Never>([])

    var accountsPublisher: AnyPublisher<[Account], Never> {
        subject.eraseToAnyPublisher()
    }

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        refresh()
    }

    private func makeRequest() -> NSFetchRequest<AccountCD> {
        AccountCD.fetchRequest() as! NSFetchRequest<AccountCD>
    }

    func fetchAll() -> [Account] {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountCD.createdAt, ascending: true)]

        do {
            return try context.fetch(request).map { $0.toDomain() }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchActive() -> [Account] {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountCD.createdAt, ascending: true)]

        do {
            return try context.fetch(request).map { $0.toDomain() }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchAccount(id: UUID) -> Account? {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try context.fetch(request).first?.toDomain()
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ account: Account) throws {
        let context = coreDataStack.viewContext
        AccountCD.fromDomain(account, context: context)
        try context.save()
        refresh()
    }

    func update(_ account: Account) throws {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)

        if let existing = try context.fetch(request).first {
            existing.name = account.name
            existing.type = account.type.rawValue
            existing.balance = account.balance
            existing.institution = account.institution
            existing.color = account.color
            existing.icon = account.icon
            existing.isActive = account.isActive
            try context.save()
            refresh()
        }
    }

    func delete(_ account: Account) throws {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)

        if let existing = try context.fetch(request).first {
            context.delete(existing)
            try context.save()
            refresh()
        }
    }

    private func refresh() {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountCD.createdAt, ascending: true)]

        do {
            let results = try context.fetch(request)
            subject.send(results.map { $0.toDomain() })
        } catch {
            print("Refresh error: \(error.localizedDescription)")
        }
    }
}
