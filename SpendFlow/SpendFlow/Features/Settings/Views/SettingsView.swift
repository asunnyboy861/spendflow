import SwiftUI

struct SettingsView: View {
    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository

    init(budgetRepository: BudgetRepository, transactionRepository: TransactionRepository) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
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
                    SettingsRow(icon: "icloud", iconColor: .accentBlue, title: "iCloud Sync", value: "Off")
                    SettingsRow(icon: "square.and.arrow.up", iconColor: .warningOrange, title: "Export CSV")
                }

                Section("About") {
                    SettingsRow(icon: "info.circle", iconColor: .accentBlue, title: "Version", value: AppConstants.appVersion)
                    SettingsRow(icon: "star", iconColor: .warningOrange, title: "Rate SpendFlow")
                    SettingsRow(icon: "envelope", iconColor: .accentBlue, title: "Contact Support")
                    SettingsRow(icon: "doc.text", iconColor: .secondary, title: "Privacy Policy")
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
        }
    }
}
