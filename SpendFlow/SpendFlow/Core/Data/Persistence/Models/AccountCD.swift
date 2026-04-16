import CoreData

@objc(AccountCD)
class AccountCD: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var balance: Double
    @NSManaged var institution: String?
    @NSManaged var color: String
    @NSManaged var icon: String
    @NSManaged var isActive: Bool
    @NSManaged var createdAt: Date
}

extension AccountCD {
    func toDomain() -> Account {
        Account(
            id: id,
            name: name,
            type: AccountType(rawValue: type) ?? .bank,
            balance: balance,
            institution: institution,
            color: color,
            icon: icon,
            isActive: isActive
        )
    }

    @discardableResult
    static func fromDomain(_ domain: Account, context: NSManagedObjectContext) -> AccountCD {
        let cd = AccountCD(context: context)
        cd.id = domain.id
        cd.name = domain.name
        cd.type = domain.type.rawValue
        cd.balance = domain.balance
        cd.institution = domain.institution
        cd.color = domain.color
        cd.icon = domain.icon
        cd.isActive = domain.isActive
        cd.createdAt = domain.createdAt
        return cd
    }
}
