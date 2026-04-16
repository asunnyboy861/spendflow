import SwiftUI

struct ExportOptionsView: View {
    @ObservedObject var viewModel: ExportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("Export Options")
                .font(.headline)
                .foregroundColor(.primary)

            dateRangeSection
            formatSection
            dataTypesSection
        }
    }

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            Text("Date Range")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                DatePicker("From", selection: Binding(
                    get: { viewModel.options.startDate },
                    set: { viewModel.setDateRange(start: $0, end: viewModel.options.endDate) }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)

                DatePicker("To", selection: Binding(
                    get: { viewModel.options.endDate },
                    set: { viewModel.setDateRange(start: viewModel.options.startDate, end: $0) }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
            }

            if !viewModel.isValidDateRange {
                Text("End date must be after start date")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Text(viewModel.dateRangeDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var formatSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            Text("Format")
                .font(.subheadline)
                .fontWeight(.medium)

            Picker("Format", selection: Binding(
                get: { viewModel.options.format },
                set: { viewModel.setFormat($0) }
            )) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var dataTypesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            Text("Data to Export")
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(spacing: 0) {
                Toggle("Transactions", isOn: Binding(
                    get: { viewModel.options.includeTransactions },
                    set: { _ in viewModel.toggleIncludeTransactions() }
                ))
                .padding(.vertical, DesignTokens.Spacing.s)

                Divider()

                Toggle("Budgets", isOn: Binding(
                    get: { viewModel.options.includeBudgets },
                    set: { _ in viewModel.toggleIncludeBudgets() }
                ))
                .padding(.vertical, DesignTokens.Spacing.s)

                Divider()

                Toggle("Accounts", isOn: Binding(
                    get: { viewModel.options.includeAccounts },
                    set: { _ in viewModel.toggleIncludeAccounts() }
                ))
                .padding(.vertical, DesignTokens.Spacing.s)
            }
        }
    }
}
