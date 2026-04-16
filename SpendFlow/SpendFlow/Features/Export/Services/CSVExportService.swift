import Foundation
import Combine

enum ExportError: Error {
    case noDataToExport
    case fileCreationFailed
    case invalidDateRange
    case permissionDenied

    var localizedDescription: String {
        switch self {
        case .noDataToExport:
            return "No data available to export"
        case .fileCreationFailed:
            return "Failed to create export file"
        case .invalidDateRange:
            return "Invalid date range selected"
        case .permissionDenied:
            return "Permission denied to save file"
        }
    }
}

enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case json = "JSON"

    var fileExtension: String {
        switch self {
        case .csv: return "csv"
        case .json: return "json"
        }
    }

    var mimeType: String {
        switch self {
        case .csv: return "text/csv"
        case .json: return "application/json"
        }
    }
}

struct ExportOptions {
    var startDate: Date
    var endDate: Date
    var format: ExportFormat
    var includeTransactions: Bool
    var includeBudgets: Bool
    var includeAccounts: Bool

    static var `default`: ExportOptions {
        ExportOptions(
            startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
            endDate: Date(),
            format: .csv,
            includeTransactions: true,
            includeBudgets: true,
            includeAccounts: true
        )
    }
}

protocol CSVExportService {
    func exportTransactions(
        _ transactions: [Transaction],
        options: ExportOptions
    ) async throws -> URL

    func exportAllData(
        transactions: [Transaction],
        budgets: [Budget],
        accounts: [Account],
        options: ExportOptions
    ) async throws -> URL
}

class DefaultCSVExportService: CSVExportService {

    private let fileManager = FileManager.default

    func exportTransactions(
        _ transactions: [Transaction],
        options: ExportOptions
    ) async throws -> URL {
        guard !transactions.isEmpty else {
            throw ExportError.noDataToExport
        }

        let filteredTransactions = transactions.filter {
            $0.date >= options.startDate && $0.date <= options.endDate
        }

        guard !filteredTransactions.isEmpty else {
            throw ExportError.noDataToExport
        }

        let csvContent = buildCSV(from: filteredTransactions)
        return try await saveToFile(content: csvContent, filename: "transactions", format: options.format)
    }

    func exportAllData(
        transactions: [Transaction],
        budgets: [Budget],
        accounts: [Account],
        options: ExportOptions
    ) async throws -> URL {
        var csvContent = ""

        if options.includeTransactions {
            csvContent += "# Transactions\n"
            csvContent += buildCSV(from: transactions)
            csvContent += "\n\n"
        }

        if options.includeBudgets {
            csvContent += "# Budgets\n"
            csvContent += buildBudgetsCSV(from: budgets)
            csvContent += "\n\n"
        }

        if options.includeAccounts {
            csvContent += "# Accounts\n"
            csvContent += buildAccountsCSV(from: accounts)
        }

        return try await saveToFile(content: csvContent, filename: "spendflow_export", format: options.format)
    }

    private func buildCSV(from transactions: [Transaction]) -> String {
        var csv = "Date,Type,Category,Amount,Note,Account\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        for transaction in transactions.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: transaction.date)
            let type = transaction.type.rawValue.capitalized
            let category = escapeCSVField(transaction.category)
            let amount = String(format: "%.2f", transaction.amount)
            let note = escapeCSVField(transaction.note ?? "")
            let account = ""

            csv += "\(date),\(type),\(category),\(amount),\(note),\(account)\n"
        }

        return csv
    }

    private func buildBudgetsCSV(from budgets: [Budget]) -> String {
        var csv = "Period,Category,Amount\n"

        for budget in budgets {
            let period = budget.period.rawValue
            let category = escapeCSVField(budget.category ?? "All Categories")
            let amount = String(format: "%.2f", budget.amount)

            csv += "\(period),\(category),\(amount)\n"
        }

        return csv
    }

    private func buildAccountsCSV(from accounts: [Account]) -> String {
        var csv = "Name,Type,Balance\n"

        for account in accounts {
            let name = escapeCSVField(account.name)
            let type = account.type.rawValue
            let balance = String(format: "%.2f", account.balance)

            csv += "\(name),\(type),\(balance)\n"
        }

        return csv
    }

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }

    private func saveToFile(content: String, filename: String, format: ExportFormat) async throws -> URL {
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(filename).\(format.fileExtension)")

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            throw ExportError.fileCreationFailed
        }
    }
}
