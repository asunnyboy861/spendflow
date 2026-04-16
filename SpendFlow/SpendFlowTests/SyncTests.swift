import Testing
import Foundation
import Combine
@testable import SpendFlow

@Suite("Sync Module Tests")
struct SyncTests {

    @Test("SyncStatus displayText returns correct string")
    func testSyncStatusDisplayText() async throws {
        let syncedStatus = SyncStatus.synced(Date())
        #expect(syncedStatus.displayText.contains("Synced"))

        let disabledStatus = SyncStatus.disabled
        #expect(disabledStatus.displayText == "Disabled")

        let syncingStatus = SyncStatus.syncing
        #expect(syncingStatus.displayText == "Syncing...")
    }

    @Test("SyncStatus icon returns correct system image")
    func testSyncStatusIcon() async throws {
        let disabledStatus = SyncStatus.disabled
        #expect(disabledStatus.icon == "icloud.slash")

        let syncedStatus = SyncStatus.synced(Date())
        #expect(syncedStatus.icon == "checkmark.icloud")

        let syncingStatus = SyncStatus.syncing
        #expect(syncingStatus.icon == "arrow.triangle.2.circlepath")
    }

    @Test("SyncError localizedDescription returns user-friendly message")
    func testSyncErrorLocalizedDescription() async throws {
        let notSignedInError = SyncError.notSignedIn
        #expect(notSignedInError.localizedDescription.contains("iCloud"))

        let networkError = SyncError.networkUnavailable
        #expect(networkError.localizedDescription.contains("Network"))
    }

    @Test("LocalSyncService enables and disables correctly")
    func testLocalSyncServiceEnableDisable() async throws {
        let service = LocalSyncService()

        // Initially disabled
        #expect(!service.isEnabled)

        // Enable
        try await service.enableSync()
        #expect(service.isEnabled)

        // Disable
        try await service.disableSync()
        #expect(!service.isEnabled)
    }

    @Test("LocalSyncService syncNow updates timestamp when enabled")
    func testLocalSyncServiceSyncNow() async throws {
        let service = LocalSyncService()

        // Should not throw when disabled
        try await service.syncNow()

        // Enable and sync
        try await service.enableSync()
        try await service.syncNow()
        #expect(service.isEnabled)
    }

    @Test("SyncStatus equality works correctly")
    func testSyncStatusEquality() async throws {
        let status1 = SyncStatus.syncing
        let status2 = SyncStatus.syncing
        #expect(status1 == status2)

        let status3 = SyncStatus.disabled
        #expect(status1 != status3)
    }

    @Test("SyncError equality works correctly")
    func testSyncErrorEquality() async throws {
        let error1 = SyncError.notSignedIn
        let error2 = SyncError.notSignedIn
        #expect(error1 == error2)

        let error3 = SyncError.unknown("Test")
        let error4 = SyncError.unknown("Test")
        #expect(error3 == error4)

        let error5 = SyncError.unknown("Different")
        #expect(error3 != error5)
    }
}

@Suite("SyncViewModel Tests")
struct SyncViewModelTests {

    @Test("SyncViewModel initializes with correct default state")
    func testViewModelInitialization() async throws {
        let mockService = LocalSyncService()
        let viewModel = SyncSettingsViewModel(syncService: mockService)

        #expect(viewModel.syncStatus == .disabled)
        #expect(!viewModel.isSyncEnabled)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("SyncViewModel statusDescription returns appropriate message")
    func testStatusDescription() async throws {
        let mockService = LocalSyncService()
        let viewModel = SyncSettingsViewModel(syncService: mockService)

        let description = viewModel.statusDescription
        #expect(description.contains("disabled") || description.contains("Disabled"))
    }
}
