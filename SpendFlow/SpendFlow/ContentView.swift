import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private let accountRepository: AccountRepository
    private let syncService: SyncService
    private let exportService: CSVExportService
    private let suggestionService: CategorySuggestionService
    private let bankSyncService: BankSyncService

    init() {
        let stack = CoreDataStack.shared
        transactionRepository = TransactionRepositoryImpl(coreDataStack: stack)
        budgetRepository = BudgetRepositoryImpl(coreDataStack: stack)
        accountRepository = AccountRepositoryImpl(coreDataStack: stack)
        exportService = DefaultCSVExportService()

        // Use local sync by default; user can enable iCloud in settings
        syncService = LocalSyncService()
        
        // Initialize category suggestion service
        let ruleSuggester = RuleBasedSuggester()
        let learningService = CategoryLearningService()
        suggestionService = CompositeCategorySuggestionService(
            ruleBasedSuggester: ruleSuggester,
            learningService: learningService
        )
        
        // Initialize bank sync service (using mock for now)
        bankSyncService = MockBankSyncService()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository,
                accountRepository: accountRepository,
                suggestionService: suggestionService
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

            InsightsView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository
            )
            .tabItem {
                Label("Insights", systemImage: "chart.bar.xaxis")
            }
            .tag(3)

            AccountsListView(accountRepository: accountRepository)
                .tabItem {
                    Label("Accounts", systemImage: "wallet.pass.fill")
                }
                .tag(4)

            SettingsView(
                budgetRepository: budgetRepository,
                transactionRepository: transactionRepository,
                accountRepository: accountRepository,
                syncService: syncService,
                exportService: exportService,
                bankSyncService: bankSyncService
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(5)
        }
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
