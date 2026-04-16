import SwiftUI

struct SettingsView: View {
    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository
    private let accountRepository: AccountRepository
    private let syncService: SyncService
    private let exportService: CSVExportService

    @State private var showSyncSettings = false
    @State private var showExportView = false
    @State private var showContactSupport = false

    init(
        budgetRepository: BudgetRepository,
        transactionRepository: TransactionRepository,
        accountRepository: AccountRepository,
        syncService: SyncService,
        exportService: CSVExportService
    ) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.accountRepository = accountRepository
        self.syncService = syncService
        self.exportService = exportService
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Budget") {
                    NavigationLink {
                        BudgetSettingsView(budgetRepository: budgetRepository)
                    } label: {
                        SettingsRow(icon: "slider.horizontal.3", iconColor: .accentBlue, title: "Budget Settings")
                    }
                }

                Section("Security") {
                    SettingsRow(icon: "faceid", iconColor: .incomeGreen, title: "Face ID / Touch ID", value: BiometricAuth.isAvailable ? "Available" : "Not Available")
                }

                Section("Data") {
                    Button {
                        showSyncSettings = true
                    } label: {
                        SettingsRow(icon: "icloud", iconColor: .accentBlue, title: "iCloud Sync", value: "Off")
                    }

                    Button {
                        showExportView = true
                    } label: {
                        SettingsRow(icon: "square.and.arrow.up", iconColor: .warningOrange, title: "Export Data")
                    }
                }

                Section("About") {
                    SettingsRow(icon: "info.circle", iconColor: .accentBlue, title: "Version", value: AppConstants.appVersion)
                    SettingsRow(icon: "star", iconColor: .warningOrange, title: "Rate SpendFlow")
                    Button {
                        showContactSupport = true
                    } label: {
                        SettingsRow(icon: "envelope", iconColor: .accentBlue, title: "Contact Support")
                    }
                    Link(destination: AppConstants.supportURL) {
                        SettingsRow(icon: "questionmark.circle", iconColor: .accentBlue, title: "Technical Support")
                    }
                    Link(destination: AppConstants.privacyPolicyURL) {
                        SettingsRow(icon: "doc.text", iconColor: .secondary, title: "Privacy Policy")
                    }
                    Link(destination: AppConstants.termsOfServiceURL) {
                        SettingsRow(icon: "doc.text.fill", iconColor: .secondary, title: "Terms of Service")
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text("SpendFlow v\(AppConstants.appVersion)")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showSyncSettings) {
                let syncViewModel = SyncSettingsViewModel(syncService: syncService)
                SyncSettingsView(viewModel: syncViewModel)
            }
            .sheet(isPresented: $showExportView) {
                let exportViewModel = ExportViewModel(
                    exportService: exportService,
                    transactionRepository: transactionRepository,
                    budgetRepository: budgetRepository,
                    accountRepository: accountRepository
                )
                ExportView(viewModel: exportViewModel)
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
        }
    }
}
