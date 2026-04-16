import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private let accountRepository: AccountRepository
    private let syncService: SyncService
    private let exportService: CSVExportService

    init() {
        let stack = CoreDataStack.shared
        transactionRepository = TransactionRepositoryImpl(coreDataStack: stack)
        budgetRepository = BudgetRepositoryImpl(coreDataStack: stack)
        accountRepository = AccountRepositoryImpl(coreDataStack: stack)
        exportService = DefaultCSVExportService()

        // Use local sync by default; user can enable iCloud in settings
        syncService = LocalSyncService()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository,
                accountRepository: accountRepository
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            TransactionListView(transactionRepository: transactionRepository)
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangleportait")
                }
                .tag(1)

            BudgetOverviewView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository
            )
            .tabItem {
                Label("Budget", systemImage: "chart.pie.fill")
            }
            .tag(2)

            AccountsListView(accountRepository: accountRepository)
                .tabItem {
                    Label("Accounts", systemImage: "wallet.pass.fill")
                }
                .tag(3)

            SettingsView(
                budgetRepository: budgetRepository,
                transactionRepository: transactionRepository,
                accountRepository: accountRepository,
                syncService: syncService,
                exportService: exportService
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
