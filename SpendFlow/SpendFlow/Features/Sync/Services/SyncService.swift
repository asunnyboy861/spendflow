import Foundation
import Combine

protocol SyncService {
    var syncStatusPublisher: AnyPublisher<SyncStatus, Never> { get }
    var isEnabled: Bool { get set }

    func enableSync() async throws
    func disableSync() async throws
    func syncNow() async throws
    func resolveConflict(with resolution: ConflictResolution) async throws
}

enum ConflictResolution {
    case keepLocal
    case keepRemote
    case merge
}
