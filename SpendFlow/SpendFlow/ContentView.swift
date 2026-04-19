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

        syncService = LocalSyncService()
        
        let ruleSuggester = RuleBasedSuggester()
        let learningService = CategoryLearningService()
        suggestionService = CompositeCategorySuggestionService(
            ruleBasedSuggester: ruleSuggester,
            learningService: learningService
        )
        
        bankSyncService = MockBankSyncService()
    }

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
    }
    
    @ViewBuilder
    private var iPadLayout: some View {
        NavigationSplitView {
            sidebarList
                .navigationTitle("SpendFlow")
                .listStyle(.sidebar)
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private var sidebarList: some View {
        List {
            sidebarItem(icon: "house.fill", title: "Home", tag: 0)
            sidebarItem(icon: "list.bullet.rectangleportait", title: "Transactions", tag: 1)
            sidebarItem(icon: "chart.pie.fill", title: "Budget", tag: 2)
            sidebarItem(icon: "chart.bar.xaxis", title: "Insights", tag: 3)
            sidebarItem(icon: "wallet.pass.fill", title: "Accounts", tag: 4)
            sidebarItem(icon: "gearshape.fill", title: "Settings", tag: 5)
        }
    }
    
    private func sidebarItem(icon: String, title: String, tag: Int) -> some View {
        Button {
            selectedTab = tag
        } label: {
            Label(title, systemImage: icon)
        }
        .listRowBackground(selectedTab == tag ? Color.accentColor.opacity(0.15) : Color.clear)
    }
    
    @ViewBuilder
    private var iPhoneLayout: some View {
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
                    Label("Transactions", systemImage: "list.bullet.rectangle.portrait")
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
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case 0:
            DashboardView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository,
                accountRepository: accountRepository,
                suggestionService: suggestionService
            )
        case 1:
            TransactionListView(transactionRepository: transactionRepository)
        case 2:
            BudgetOverviewView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository
            )
        case 3:
            InsightsView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository
            )
        case 4:
            AccountsListView(accountRepository: accountRepository)
        case 5:
            SettingsView(
                budgetRepository: budgetRepository,
                transactionRepository: transactionRepository,
                accountRepository: accountRepository,
                syncService: syncService,
                exportService: exportService,
                bankSyncService: bankSyncService
            )
        default:
            DashboardView(
                transactionRepository: transactionRepository,
                budgetRepository: budgetRepository,
                accountRepository: accountRepository,
                suggestionService: suggestionService
            )
        }
    }
}

#Preview {
    ContentView()
}
