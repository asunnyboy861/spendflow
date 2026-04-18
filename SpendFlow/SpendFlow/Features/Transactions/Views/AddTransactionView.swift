import SwiftUI

struct AddTransactionView: View {
    @StateObject private var viewModel: AddTransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAmountFocused: Bool

    init(
        transactionRepository: TransactionRepository,
        suggestionService: CategorySuggestionService
    ) {
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel(
            transactionRepository: transactionRepository,
            suggestionService: suggestionService
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    typePicker

                    AmountInputField(amount: $viewModel.amount, placeholder: "0.00")
                        .focused($isAmountFocused)

                    if viewModel.showSuggestion, let suggested = viewModel.suggestedCategory {
                        suggestionBanner(suggested)
                    }

                    CategoryPicker(
                        selectedCategory: $viewModel.selectedCategory,
                        categories: viewModel.categories
                    )

                    noteField

                    HapticButton("Save Transaction") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.amount.isEmpty)
                    .opacity(viewModel.amount.isEmpty ? 0.5 : 1.0)
                }
                .padding(DesignTokens.Spacing.m)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isAmountFocused = true
            }
        }
    }
    
    private func suggestionBanner(_ category: Category) -> some View {
        HStack(spacing: DesignTokens.Spacing.s) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.accentBlue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Suggested Category")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button("Apply") {
                viewModel.acceptSuggestion()
            }
            .font(.caption)
            .fontWeight(.semibold)
            .buttonStyle(.bordered)
        }
        .padding(DesignTokens.Spacing.s)
        .background(Color.accentBlue.opacity(0.1))
        .cornerRadius(8)
    }

    private var typePicker: some View {
        Picker("Type", selection: $viewModel.transactionType) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.transactionType) { _, newValue in
            viewModel.switchType(newValue)
        }
    }

    private var noteField: some View {
        TextField("Note (optional)", text: $viewModel.note)
            .textFieldStyle(.roundedBorder)
            .font(.body)
    }
}
