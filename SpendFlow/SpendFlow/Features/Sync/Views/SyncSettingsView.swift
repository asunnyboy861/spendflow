import SwiftUI

struct SyncSettingsView: View {
    @StateObject private var viewModel: SyncSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SyncSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    syncStatusSection
                    syncToggleSection
                    syncActionSection
                    infoSection
                }
                .padding(.horizontal, DesignTokens.Spacing.m)
                .padding(.vertical, DesignTokens.Spacing.m)
            }
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Sync Conflict", isPresented: $viewModel.showConflictAlert) {
                Button("Keep Local", role: .none) {
                    viewModel.resolveConflict(keeping: .keepLocal)
                }
                Button("Keep Remote", role: .none) {
                    viewModel.resolveConflict(keeping: .keepRemote)
                }
                Button("Merge", role: .none) {
                    viewModel.resolveConflict(keeping: .merge)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Data conflict detected. Choose which version to keep.")
            }
        }
    }

    private var syncStatusSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            SyncStatusIndicator(status: viewModel.syncStatus)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, DesignTokens.Spacing.xs)
            }

            Text(viewModel.statusDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    private var syncToggleSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            SyncToggle(isEnabled: $viewModel.isSyncEnabled) {
                viewModel.toggleSync()
            }
            .disabled(viewModel.isLoading)
        }
        .cardStyle()
    }

    private var syncActionSection: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            HapticButton("Sync Now", style: .secondary) {
                viewModel.syncNow()
            }
            .disabled(viewModel.isLoading || !viewModel.isSyncEnabled)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .cardStyle()
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Label {
                Text("Your data is stored locally by default. Enable iCloud Sync to backup and sync across your Apple devices.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "info.circle")
                    .foregroundColor(.accentColor)
            }

            Label {
                Text("iCloud Sync requires an active iCloud account and internet connection.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "wifi")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.s)
    }
}
