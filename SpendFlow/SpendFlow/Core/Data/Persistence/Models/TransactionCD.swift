import CoreData

@objc(TransactionCD)
class TransactionCD: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var amount: Double
    @NSManaged var category: String
    @NSManaged var date: Date
    @NSManaged var note: String?
    @NSManaged var accountID: UUID?
    @NSManaged var type: String
    @NSManaged var isRecurring: Bool
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
}

extension TransactionCD {
    func toDomain() -> Transaction {
        Transaction(
            id: id,
            amount: amount,
            category: category,
            date: date,
            note: note,
            accountID: accountID,
            type: TransactionType(rawValue: type) ?? .expense,
            isRecurring: isRecurring
        )
    }

    @discardableResult
    static func fromDomain(_ domain: Transaction, context: NSManagedObjectContext) -> TransactionCD {
        let cd = TransactionCD(context: context)
        cd.id = domain.id
        cd.amount = domain.amount
        cd.category = domain.category
        cd.date = domain.date
        cd.note = domain.note
        cd.accountID = domain.accountID
        cd.type = domain.type.rawValue
        cd.isRecurring = domain.isRecurring
        cd.createdAt = domain.createdAt
        cd.updatedAt = domain.updatedAt
        return cd
    }
}
