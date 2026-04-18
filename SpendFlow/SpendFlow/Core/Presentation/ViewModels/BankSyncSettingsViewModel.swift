import Combine
import Foundation

class BankSyncSettingsViewModel: ObservableObject {
    @Published var syncStatus: BankSyncStatus = .notConnected
    @Published var connectedAccounts: [BankAccount] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingConnectionSheet: Bool = false
    
    private let bankSyncService: BankSyncService
    private let transactionRepository: TransactionRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(
        bankSyncService: BankSyncService,
        transactionRepository: TransactionRepository
    ) {
        self.bankSyncService = bankSyncService
        self.transactionRepository = transactionRepository
        setupBindings()
    }
    
    private func setupBindings() {
        bankSyncService.syncStatusPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$syncStatus)
        
        bankSyncService.connectedAccountsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectedAccounts)
    }
    
    func connectBank() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                let publicToken = try await bankSyncService.connectBank()
                try await bankSyncService.completeConnection(publicToken: publicToken)
            } catch let error as BankSyncError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func syncAccount(_ accountId: UUID) {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                try await bankSyncService.syncTransactions(for: accountId)
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func syncAllAccounts() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                try await bankSyncService.syncAllAccounts()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func disconnectAccount(_ accountId: UUID) {
        Task {
            do {
                try await bankSyncService.disconnectAccount(accountId)
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func refreshAccount(_ accountId: UUID) {
        Task {
            do {
                try await bankSyncService.refreshAccount(accountId)
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var hasConnectedBanks: Bool {
        !connectedAccounts.isEmpty
    }
}
