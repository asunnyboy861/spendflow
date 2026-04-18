import Foundation
import Combine

protocol BankSyncService {
    var syncStatusPublisher: AnyPublisher<BankSyncStatus, Never> { get }
    var connectedAccountsPublisher: AnyPublisher<[BankAccount], Never> { get }
    
    func connectBank() async throws -> String
    func completeConnection(publicToken: String) async throws
    func syncTransactions(for accountId: UUID) async throws
    func syncAllAccounts() async throws
    func disconnectAccount(_ accountId: UUID) async throws
    func refreshAccount(_ accountId: UUID) async throws
}

class MockBankSyncService: BankSyncService {
    
    private let syncStatusSubject = CurrentValueSubject<BankSyncStatus, Never>(.notConnected)
    private let connectedAccountsSubject = CurrentValueSubject<[BankAccount], Never>([])
    
    var syncStatusPublisher: AnyPublisher<BankSyncStatus, Never> {
        syncStatusSubject.eraseToAnyPublisher()
    }
    
    var connectedAccountsPublisher: AnyPublisher<[BankAccount], Never> {
        connectedAccountsSubject.eraseToAnyPublisher()
    }
    
    func connectBank() async throws -> String {
        await MainActor.run {
            syncStatusSubject.send(.connecting)
        }
        
        // Simulate connection delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Return mock public token
        return "mock-public-token-\(UUID().uuidString)"
    }
    
    func completeConnection(publicToken: String) async throws {
        await MainActor.run {
            syncStatusSubject.send(.connecting)
        }
        
        // Simulate token exchange
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Add mock accounts
        let mockAccounts = [
            BankAccount(
                plaidAccountId: "mock-checking-1",
                bankName: "Chase",
                accountName: "Checking",
                accountType: .checking,
                accountSubtype: "checking",
                balance: 5432.10,
                lastSyncDate: Date()
            ),
            BankAccount(
                plaidAccountId: "mock-savings-1",
                bankName: "Chase",
                accountName: "Savings",
                accountType: .savings,
                accountSubtype: "savings",
                balance: 12500.00,
                lastSyncDate: Date()
            ),
            BankAccount(
                plaidAccountId: "mock-credit-1",
                bankName: "Chase",
                accountName: "Freedom Unlimited",
                accountType: .credit,
                accountSubtype: "credit card",
                balance: -1234.56,
                lastSyncDate: Date()
            )
        ]
        
        await MainActor.run {
            connectedAccountsSubject.send(mockAccounts)
            syncStatusSubject.send(.connected(Date()))
        }
    }
    
    func syncTransactions(for accountId: UUID) async throws {
        await MainActor.run {
            syncStatusSubject.send(.syncing)
        }
        
        // Simulate sync
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            syncStatusSubject.send(.synced(Date()))
        }
    }
    
    func syncAllAccounts() async throws {
        await MainActor.run {
            syncStatusSubject.send(.syncing)
        }
        
        // Simulate sync
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        await MainActor.run {
            syncStatusSubject.send(.synced(Date()))
        }
    }
    
    func disconnectAccount(_ accountId: UUID) async throws {
        var accounts = connectedAccountsSubject.value
        accounts.removeAll { $0.id == accountId }
        
        await MainActor.run {
            connectedAccountsSubject.send(accounts)
            
            if accounts.isEmpty {
                syncStatusSubject.send(.notConnected)
            }
        }
    }
    
    func refreshAccount(_ accountId: UUID) async throws {
        await MainActor.run {
            syncStatusSubject.send(.syncing)
        }
        
        // Simulate refresh
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            syncStatusSubject.send(.synced(Date()))
        }
    }
}
