import Combine
import Foundation

class SyncSettingsViewModel: ObservableObject {
    @Published var syncStatus: SyncStatus = .disabled
    @Published var isSyncEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showConflictAlert: Bool = false

    private let syncService: SyncService
    private var cancellables = Set<AnyCancellable>()

    init(syncService: SyncService) {
        self.syncService = syncService
        setupBindings()
    }

    private func setupBindings() {
        syncService.syncStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.syncStatus = status
                if case .conflict = status {
                    self?.showConflictAlert = true
                }
            }
            .store(in: &cancellables)
    }

    func toggleSync() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }

            do {
                if isSyncEnabled {
                    try await syncService.enableSync()
                } else {
                    try await syncService.disableSync()
                }
            } catch let error as SyncError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSyncEnabled = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSyncEnabled = false
                }
            }

            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    func syncNow() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }

            do {
                try await syncService.syncNow()
            } catch let error as SyncError {
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

    func resolveConflict(keeping resolution: ConflictResolution) {
        Task {
            await MainActor.run {
                self.isLoading = true
            }

            do {
                try await syncService.resolveConflict(with: resolution)
                await MainActor.run {
                    self.showConflictAlert = false
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

    var statusDescription: String {
        switch syncStatus {
        case .notConfigured:
            return "Sign in to iCloud to enable sync across your devices"
        case .disabled:
            return "Sync is currently disabled. Enable to backup your data to iCloud"
        case .syncing:
            return "Syncing your data..."
        case .synced:
            return "Your data is up to date across all devices"
        case .failed:
            return errorMessage ?? "Sync failed. Please try again"
        case .conflict:
            return "Data conflict detected. Please choose which version to keep"
        }
    }
}
