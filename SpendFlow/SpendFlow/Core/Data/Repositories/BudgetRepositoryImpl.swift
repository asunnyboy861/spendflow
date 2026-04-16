import Combine
import CoreData

class BudgetRepositoryImpl: BudgetRepository {
    private let coreDataStack: CoreDataStack
    private let subject = CurrentValueSubject<[Budget], Never>([])

    var budgetsPublisher: AnyPublisher<[Budget], Never> {
        subject.eraseToAnyPublisher()
    }

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        refresh()
    }

    private func makeRequest() -> NSFetchRequest<BudgetCD> {
        BudgetCD.fetchRequest() as! NSFetchRequest<BudgetCD>
    }

    func fetchAll() -> [Budget] {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BudgetCD.createdAt, ascending: false)]

        do {
            return try context.fetch(request).map { $0.toDomain() }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchBudget(for period: BudgetPeriod) -> Budget? {
        fetchBudget(for: period, category: nil)
    }

    func fetchBudget(for period: BudgetPeriod, category: String?) -> Budget? {
        let context = coreDataStack.viewContext
        let request = makeRequest()

        if let category {
            request.predicate = NSPredicate(format: "period == %@ AND category == %@ AND isActive == YES", period.rawValue, category)
        } else {
            request.predicate = NSPredicate(format: "period == %@ AND category == nil AND isActive == YES", period.rawValue)
        }

        do {
            return try context.fetch(request).first?.toDomain()
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ budget: Budget) throws {
        let context = coreDataStack.viewContext
        BudgetCD.fromDomain(budget, context: context)
        try context.save()
        refresh()
    }

    func update(_ budget: Budget) throws {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)

        if let existing = try context.fetch(request).first {
            existing.amount = budget.amount
            existing.period = budget.period.rawValue
            existing.startDate = budget.startDate
            existing.category = budget.category
            existing.isActive = budget.isActive
            try context.save()
            refresh()
        }
    }

    func delete(_ budget: Budget) throws {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)

        if let existing = try context.fetch(request).first {
            context.delete(existing)
            try context.save()
            refresh()
        }
    }

    private func refresh() {
        let context = coreDataStack.viewContext
        let request = makeRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BudgetCD.createdAt, ascending: false)]

        do {
            let results = try context.fetch(request)
            subject.send(results.map { $0.toDomain() })
        } catch {
            print("Refresh error: \(error.localizedDescription)")
        }
    }
}
