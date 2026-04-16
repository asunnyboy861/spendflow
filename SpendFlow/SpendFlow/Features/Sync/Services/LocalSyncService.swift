import Foundation
import Combine

class LocalSyncService: SyncService {

    private let syncStatusSubject = CurrentValueSubject<SyncStatus, Never>(.disabled)

    var syncStatusPublisher: AnyPublisher<SyncStatus, Never> {
        syncStatusSubject.eraseToAnyPublisher()
    }

    var isEnabled: Bool = false {
        didSet {
            syncStatusSubject.send(isEnabled ? .synced(Date()) : .disabled)
        }
    }

    func enableSync() async throws {
        isEnabled = true
        syncStatusSubject.send(.synced(Date()))
    }

    func disableSync() async throws {
        isEnabled = false
        syncStatusSubject.send(.disabled)
    }

    func syncNow() async throws {
        guard isEnabled else { return }
        syncStatusSubject.send(.synced(Date()))
    }

    func resolveConflict(with resolution: ConflictResolution) async throws {
        // Local sync doesn't have conflicts
    }
}
