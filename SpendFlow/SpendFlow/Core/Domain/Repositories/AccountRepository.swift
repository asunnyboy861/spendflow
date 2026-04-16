import Combine
import Foundation

protocol AccountRepository {
    var accountsPublisher: AnyPublisher<[Account], Never> { get }

    func fetchAll() -> [Account]
    func fetchActive() -> [Account]
    func fetchAccount(id: UUID) -> Account?
    func save(_ account: Account) throws
    func update(_ account: Account) throws
    func delete(_ account: Account) throws
}
