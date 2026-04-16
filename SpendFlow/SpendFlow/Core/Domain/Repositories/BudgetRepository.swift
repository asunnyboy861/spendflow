import Combine
import Foundation

protocol BudgetRepository {
    var budgetsPublisher: AnyPublisher<[Budget], Never> { get }

    func fetchAll() -> [Budget]
    func fetchBudget(for period: BudgetPeriod) -> Budget?
    func fetchBudget(for period: BudgetPeriod, category: String?) -> Budget?
    func save(_ budget: Budget) throws
    func update(_ budget: Budget) throws
    func delete(_ budget: Budget) throws
}
