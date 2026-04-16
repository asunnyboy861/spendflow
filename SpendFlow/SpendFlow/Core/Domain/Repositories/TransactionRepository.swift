import Combine
import Foundation

protocol TransactionRepository {
    var transactionsPublisher: AnyPublisher<[Transaction], Never> { get }

    func fetchAll() -> [Transaction]
    func fetchTransactions(from startDate: Date, to endDate: Date) -> [Transaction]
    func fetchTransactions(forAccount accountID: UUID) -> [Transaction]
    func fetchTransactions(forCategory category: String) -> [Transaction]
    func save(_ transaction: Transaction) throws
    func update(_ transaction: Transaction) throws
    func delete(_ transaction: Transaction) throws
}
