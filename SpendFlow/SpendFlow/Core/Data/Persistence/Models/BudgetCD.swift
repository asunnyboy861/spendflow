import CoreData

@objc(BudgetCD)
class BudgetCD: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var amount: Double
    @NSManaged var period: String
    @NSManaged var startDate: Date
    @NSManaged var category: String?
    @NSManaged var isActive: Bool
    @NSManaged var createdAt: Date
}

extension BudgetCD {
    func toDomain() -> Budget {
        Budget(
            id: id,
            amount: amount,
            period: BudgetPeriod(rawValue: period) ?? .monthly,
            startDate: startDate,
            category: category,
            isActive: isActive
        )
    }

    @discardableResult
    static func fromDomain(_ domain: Budget, context: NSManagedObjectContext) -> BudgetCD {
        let cd = BudgetCD(context: context)
        cd.id = domain.id
        cd.amount = domain.amount
        cd.period = domain.period.rawValue
        cd.startDate = domain.startDate
        cd.category = domain.category
        cd.isActive = domain.isActive
        cd.createdAt = domain.createdAt
        return cd
    }
}
