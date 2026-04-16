import Combine
import Foundation
import UniformTypeIdentifiers

class ExportViewModel: ObservableObject {
    @Published var options: ExportOptions = .default
    @Published var isExporting: Bool = false
    @Published var errorMessage: String?
    @Published var showShareSheet: Bool = false
    @Published var exportedFileURL: URL?
    @Published var showSuccessMessage: Bool = false

    private let exportService: CSVExportService
    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    private let accountRepository: AccountRepository

    init(
        exportService: CSVExportService,
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository,
        accountRepository: AccountRepository
    ) {
        self.exportService = exportService
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
        self.accountRepository = accountRepository
    }

    func exportData() {
        Task {
            await MainActor.run {
                self.isExporting = true
                self.errorMessage = nil
                self.showSuccessMessage = false
            }

            do {
                let transactions = transactionRepository.fetchAll()
                let budgets = budgetRepository.fetchAll()
                let accounts = accountRepository.fetchAll()

                let url = try await exportService.exportAllData(
                    transactions: transactions,
                    budgets: budgets,
                    accounts: accounts,
                    options: options
                )

                await MainActor.run {
                    self.exportedFileURL = url
                    self.showShareSheet = true
                    self.showSuccessMessage = true
                }
            } catch let error as ExportError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Export failed: \(error.localizedDescription)"
                }
            }

            await MainActor.run {
                self.isExporting = false
            }
        }
    }

    func exportTransactionsOnly() {
        Task {
            await MainActor.run {
                self.isExporting = true
                self.errorMessage = nil
                self.showSuccessMessage = false
            }

            do {
                let transactions = transactionRepository.fetchAll()
                let url = try await exportService.exportTransactions(transactions, options: options)

                await MainActor.run {
                    self.exportedFileURL = url
                    self.showShareSheet = true
                    self.showSuccessMessage = true
                }
            } catch let error as ExportError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Export failed: \(error.localizedDescription)"
                }
            }

            await MainActor.run {
                self.isExporting = false
            }
        }
    }

    func setDateRange(start: Date, end: Date) {
        options.startDate = start
        options.endDate = end
    }

    func setFormat(_ format: ExportFormat) {
        options.format = format
    }

    func toggleIncludeTransactions() {
        options.includeTransactions.toggle()
    }

    func toggleIncludeBudgets() {
        options.includeBudgets.toggle()
    }

    func toggleIncludeAccounts() {
        options.includeAccounts.toggle()
    }

    var isValidDateRange: Bool {
        options.startDate <= options.endDate
    }

    var canExport: Bool {
        isValidDateRange && (options.includeTransactions || options.includeBudgets || options.includeAccounts)
    }

    var dateRangeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(formatter.string(from: options.startDate)) - \(formatter.string(from: options.endDate))"
    }
}
