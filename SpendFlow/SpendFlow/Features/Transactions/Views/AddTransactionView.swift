import SwiftUI

struct AddTransactionView: View {
    @StateObject private var viewModel: AddTransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAmountFocused: Bool

    init(transactionRepository: TransactionRepository) {
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel(
            transactionRepository: transactionRepository
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    typePicker

                    AmountInputField(amount: $viewModel.amount, placeholder: "0.00")
                        .focused($isAmountFocused)

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
