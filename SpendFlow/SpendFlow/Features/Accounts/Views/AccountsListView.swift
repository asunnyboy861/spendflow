import SwiftUI

struct AccountsListView: View {
    @State private var accounts: [Account] = []
    @State private var showAddAccount = false
    private let accountRepository: AccountRepository

    init(accountRepository: AccountRepository) {
        self.accountRepository = accountRepository
    }

    var body: some View {
        NavigationStack {
            Group {
                if accounts.isEmpty {
                    EmptyStateView(
                        icon: "banknote",
                        title: "No Accounts",
                        subtitle: "Add your bank accounts, credit cards, or cash to track your total balance",
                        actionLabel: "Add Account"
                    ) {
                        showAddAccount = true
                    }
                } else {
                    List {
                        Section {
                            ForEach(accounts) { account in
                                AccountCard(account: account)
                            }
                        }

                        Section {
                            HStack {
                                Spacer()
                                Text("Total Balance")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(totalBalance.currencyFormatted)
                                    .font(.title3.bold())
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAccount = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddAccount) {
                AddAccountView(accountRepository: accountRepository)
            }
            .onAppear {
                accounts = accountRepository.fetchActive()
            }
        }
    }

    private var totalBalance: Double {
        accounts.filter { $0.isActive }.reduce(0) { total, account in
            switch account.type {
            case .bank, .cash: return total + account.balance
            case .credit: return total - abs(account.balance)
            }
        }
    }
}
