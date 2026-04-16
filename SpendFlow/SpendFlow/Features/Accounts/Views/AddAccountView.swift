import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var accountType: AccountType = .bank
    @State private var balance: String = ""
    @State private var institution: String = ""
    private let accountRepository: AccountRepository

    init(accountRepository: AccountRepository) {
        self.accountRepository = accountRepository
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Account Name", text: $name)

                    Picker("Type", selection: $accountType) {
                        Text("Bank Account").tag(AccountType.bank)
                        Text("Credit Card").tag(AccountType.credit)
                        Text("Cash").tag(AccountType.cash)
                    }

                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("Balance", text: $balance)
                            .keyboardType(.decimalPad)
                    }

                    if accountType != .cash {
                        TextField("Institution (optional)", text: $institution)
                    }
                }

                Section {
                    HapticButton("Add Account") {
                        saveAccount()
                    }
                    .disabled(name.isEmpty || balance.isEmpty)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveAccount() {
        guard let balanceValue = Double(balance) else { return }

        let account = Account(
            name: name,
            type: accountType,
            balance: balanceValue,
            institution: institution.isEmpty ? nil : institution,
            color: accountType == .bank ? "007AFF" : accountType == .credit ? "FF3B30" : "34C759",
            icon: accountType == .bank ? "building.columns.fill" : accountType == .credit ? "creditcard.fill" : "banknote.fill"
        )

        do {
            try accountRepository.save(account)
            HapticFeedback.success()
            dismiss()
        } catch {
            HapticFeedback.error()
        }
    }
}
