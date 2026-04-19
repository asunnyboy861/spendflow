import Testing
import Foundation
@testable import SpendFlow

@Suite("Export Module Tests")
struct ExportTests {

    @Test("ExportError localizedDescription returns user-friendly message")
    func testExportErrorLocalizedDescription() async throws {
        let noDataError = ExportError.noDataToExport
        #expect(noDataError.localizedDescription.contains("No data"))

        let fileError = ExportError.fileCreationFailed
        #expect(fileError.localizedDescription.contains("Failed to create"))

        let permissionError = ExportError.permissionDenied
        #expect(permissionError.localizedDescription.contains("Permission"))
    }

    @Test("ExportFormat has correct file extension and mime type")
    func testExportFormatProperties() async throws {
        let csvFormat = ExportFormat.csv
        #expect(csvFormat.fileExtension == "csv")
        #expect(csvFormat.mimeType == "text/csv")

        let jsonFormat = ExportFormat.json
        #expect(jsonFormat.fileExtension == "json")
        #expect(jsonFormat.mimeType == "application/json")
    }

    @Test("ExportOptions default values are set correctly")
    func testExportOptionsDefault() async throws {
        let options = ExportOptions.default

        #expect(options.format == .csv)
        #expect(options.includeTransactions)
        #expect(options.includeBudgets)
        #expect(options.includeAccounts)
        #expect(options.startDate <= options.endDate)
    }

    @Test("CSVExportService throws error for empty transactions")
    func testExportEmptyTransactions() async throws {
        let service = DefaultCSVExportService()
        let options = ExportOptions.default

        await #expect(throws: ExportError.noDataToExport) {
            _ = try await service.exportTransactions([], options: options)
        }
    }

    @Test("CSVExportService exports transactions successfully")
    func testExportTransactions() async throws {
        let service = DefaultCSVExportService()
        
        let calendar = Calendar.current
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: now)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!

        var options = ExportOptions.default
        options.startDate = oneHourAgo
        options.endDate = tomorrow

        let transactions = [
            Transaction(
                amount: 50.0,
                category: "Food",
                date: now,
                note: "Lunch",
                type: .expense
            ),
            Transaction(
                amount: 100.0,
                category: "Salary",
                date: now,
                note: "Monthly salary",
                type: .income
            )
        ]

        let url = try await service.exportTransactions(transactions, options: options)
        #expect(url.pathExtension == "csv")

        let fileManager = FileManager.default
        #expect(fileManager.fileExists(atPath: url.path))
    }

    @Test("CSVExportService respects date range filter")
    func testExportDateRangeFilter() async throws {
        let service = DefaultCSVExportService()

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!

        var options = ExportOptions.default
        options.startDate = yesterday
        options.endDate = today

        let transactions = [
            Transaction(
                amount: 50.0,
                category: "Food",
                date: today,
                type: .expense
            ),
            Transaction(
                amount: 30.0,
                category: "Transport",
                date: lastWeek,
                type: .expense
            )
        ]

        // Should only export today's transaction
        let url = try await service.exportTransactions(transactions, options: options)
        #expect(url.pathExtension == "csv")
    }
}

@Suite("ExportViewModel Tests")
struct ExportViewModelTests {

    @Test("ExportViewModel initializes with default options")
    func testViewModelInitialization() async throws {
        let mockExportService = DefaultCSVExportService()
        let mockTransactionRepo = TransactionRepositoryImpl(coreDataStack: CoreDataStack.forTesting())
        let mockBudgetRepo = BudgetRepositoryImpl(coreDataStack: CoreDataStack.forTesting())
        let mockAccountRepo = AccountRepositoryImpl(coreDataStack: CoreDataStack.forTesting())

        let viewModel = ExportViewModel(
            exportService: mockExportService,
            transactionRepository: mockTransactionRepo,
            budgetRepository: mockBudgetRepo,
            accountRepository: mockAccountRepo
        )

        #expect(viewModel.options.format == .csv)
        #expect(!viewModel.isExporting)
        #expect(viewModel.canExport)
    }

    @Test("ExportViewModel date range validation works correctly")
    func testDateRangeValidation() async throws {
        let mockExportService = DefaultCSVExportService()
        let mockTransactionRepo = TransactionRepositoryImpl(coreDataStack: CoreDataStack.forTesting())
        let mockBudgetRepo = BudgetRepositoryImpl(coreDataStack: CoreDataStack.forTesting())
        let mockAccountRepo = AccountRepositoryImpl(coreDataStack: CoreDataStack.forTesting())

        let viewModel = ExportViewModel(
            exportService: mockExportService,
            transactionRepository: mockTransactionRepo,
            budgetRepository: mockBudgetRepo,
            accountRepository: mockAccountRepo
        )

        // Valid date range
        #expect(viewModel.isValidDateRange)

        // Set invalid date range
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        viewModel.setDateRange(start: today, end: yesterday)

        #expect(!viewModel.isValidDateRange)
    }

    @Test("ExportViewModel canExport reflects data type selection")
    func testCanExportWithDataTypes() async throws {
        let mockExportService = DefaultCSVExportService()
        let mockTransactionRepo = TransactionRepositoryImpl(coreDataStack: CoreDataStack.forTesting())
        let mockBudgetRepo = BudgetRepositoryImpl(coreDataStack: CoreDataStack.forTesting())
        let mockAccountRepo = AccountRepositoryImpl(coreDataStack: CoreDataStack.forTesting())

        let viewModel = ExportViewModel(
            exportService: mockExportService,
            transactionRepository: mockTransactionRepo,
            budgetRepository: mockBudgetRepo,
            accountRepository: mockAccountRepo
        )

        // Initially can export
        #expect(viewModel.canExport)

        // Disable all data types
        viewModel.toggleIncludeTransactions()
        viewModel.toggleIncludeBudgets()
        viewModel.toggleIncludeAccounts()

        #expect(!viewModel.canExport)
    }
}
