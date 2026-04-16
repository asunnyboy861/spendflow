import Combine
import Foundation

class AggregateAccounts: ObservableObject {
    @Published var totalBalance: Double = 0
    @Published var accounts: [Account] = []

    private let accountRepository: AccountRepository
    private var cancellables = Set<AnyCancellable>()

    init(accountRepository: AccountRepository) {
        self.accountRepository = accountRepository

        accountRepository.accountsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accounts in
                self?.accounts = accounts
                self?.calculateTotalBalance()
            }
            .store(in: &cancellables)
    }

    private func calculateTotalBalance() {
        totalBalance = accounts
            .filter { $0.isActive }
            .reduce(0) { total, account in
                switch account.type {
                case .bank, .cash:
                    return total + account.balance
                case .credit:
                    return total - abs(account.balance)
                }
            }
    }
}
