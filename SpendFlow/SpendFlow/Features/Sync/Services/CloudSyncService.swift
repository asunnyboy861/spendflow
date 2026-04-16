import Foundation
import Combine
import CloudKit

class CloudSyncService: SyncService {

    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private let accountRepository: AccountRepository
    private let container: CKContainer
    private let database: CKDatabase
    private let syncStatusSubject = CurrentValueSubject<SyncStatus, Never>(.notConfigured)

    var syncStatusPublisher: AnyPublisher<SyncStatus, Never> {
        syncStatusSubject.eraseToAnyPublisher()
    }

    var isEnabled: Bool = false {
        didSet {
            Task {
                if isEnabled {
                    try? await enableSync()
                } else {
                    try? await disableSync()
                }
            }
        }
    }

    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository,
        accountRepository: AccountRepository
    ) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
        self.accountRepository = accountRepository
        self.container = CKContainer(identifier: "iCloud.com.yourcompany.SpendFlow")
        self.database = container.privateCloudDatabase

        checkiCloudStatus()
    }

    private func checkiCloudStatus() {
        Task {
            do {
                let status = try await container.accountStatus()
                switch status {
                case .available:
                    syncStatusSubject.send(.disabled)
                case .noAccount:
                    syncStatusSubject.send(.notConfigured)
                default:
                    syncStatusSubject.send(.failed(.notSignedIn))
                }
            } catch {
                syncStatusSubject.send(.failed(.unknown(error.localizedDescription)))
            }
        }
    }

    func enableSync() async throws {
        syncStatusSubject.send(.syncing)

        do {
            let status = try await container.accountStatus()
            guard status == .available else {
                throw SyncError.notSignedIn
            }

            try await performInitialSync()

            isEnabled = true
            syncStatusSubject.send(.synced(Date()))
        } catch let error as SyncError {
            syncStatusSubject.send(.failed(error))
            throw error
        } catch {
            let syncError = SyncError.unknown(error.localizedDescription)
            syncStatusSubject.send(.failed(syncError))
            throw syncError
        }
    }

    func disableSync() async throws {
        isEnabled = false
        syncStatusSubject.send(.disabled)
    }

    func syncNow() async throws {
        guard isEnabled else { return }

        syncStatusSubject.send(.syncing)

        do {
            try await syncTransactions()
            try await syncBudgets()
            try await syncAccounts()

            syncStatusSubject.send(.synced(Date()))
        } catch {
            let syncError = SyncError.unknown(error.localizedDescription)
            syncStatusSubject.send(.failed(syncError))
            throw syncError
        }
    }

    func resolveConflict(with resolution: ConflictResolution) async throws {
        syncStatusSubject.send(.syncing)

        switch resolution {
        case .keepLocal:
            try await uploadLocalData()
        case .keepRemote:
            try await downloadRemoteData()
        case .merge:
            try await mergeData()
        }

        syncStatusSubject.send(.synced(Date()))
    }

    private func performInitialSync() async throws {
        let hasRemoteData = try await checkRemoteData()

        if hasRemoteData {
            syncStatusSubject.send(.conflict)
            throw SyncError.conflictDetected
        } else {
            try await uploadLocalData()
        }
    }

    private func syncTransactions() async throws {
        let transactions = transactionRepository.fetchAll()

        for transaction in transactions {
            let record = CKRecord(
                recordType: "Transaction",
                recordID: CKRecord.ID(recordName: transaction.id.uuidString)
            )
            record["amount"] = transaction.amount
            record["category"] = transaction.category
            record["date"] = transaction.date
            record["note"] = transaction.note ?? ""
            record["type"] = transaction.type.rawValue

            try await database.save(record)
        }
    }

    private func syncBudgets() async throws {
        // Implementation similar to syncTransactions
    }

    private func syncAccounts() async throws {
        // Implementation similar to syncTransactions
    }

    private func checkRemoteData() async throws -> Bool {
        let query = CKQuery(recordType: "Transaction", predicate: NSPredicate(value: true))
        let (results, _) = try await database.records(matching: query)
        return !results.isEmpty
    }

    private func uploadLocalData() async throws {
        try await syncTransactions()
        try await syncBudgets()
        try await syncAccounts()
    }

    private func downloadRemoteData() async throws {
        // Download and replace local data with remote data
    }

    private func mergeData() async throws {
        // Merge local and remote data
    }
}
