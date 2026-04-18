import SwiftUI

struct AddBillView: View {
    @ObservedObject var viewModel: BillReminderViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    @State private var category = "Housing"
    @State private var isRecurring = true
    @State private var recurrence: BillRecurrence = .monthly
    @State private var reminderDaysBefore = 3
    @State private var notes = ""
    
    private let categories = [
        "Housing", "Utilities", "Insurance", "Phone",
        "Internet", "Subscription", "Loan", "Credit Card",
        "Car Payment", "Other"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Bill Details") {
                    TextField("Bill Name", text: $name)
                    
                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                
                Section("Recurrence") {
                    Toggle("Recurring Bill", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Frequency", selection: $recurrence) {
                            ForEach(BillRecurrence.allCases, id: \.self) { rec in
                                Text(rec.rawValue).tag(rec)
                            }
                        }
                    }
                }
                
                Section("Reminder") {
                    Picker("Remind Me", selection: $reminderDaysBefore) {
                        Text("Same day").tag(0)
                        Text("1 day before").tag(1)
                        Text("2 days before").tag(2)
                        Text("3 days before").tag(3)
                        Text("5 days before").tag(5)
                        Text("7 days before").tag(7)
                    }
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    HapticButton("Add Bill") {
                        saveBill()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                    .opacity(name.isEmpty || amount.isEmpty ? 0.5 : 1.0)
                }
            }
            .navigationTitle("Add Bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func saveBill() {
        guard let amountValue = Double(amount) else { return }
        
        let bill = BillReminder(
            name: name,
            amount: amountValue,
            dueDate: dueDate,
            category: category,
            isRecurring: isRecurring,
            recurrence: recurrence,
            reminderDaysBefore: reminderDaysBefore,
            notes: notes
        )
        
        viewModel.addBill(bill)
        dismiss()
    }
}

#Preview {
    AddBillView(viewModel: BillReminderViewModel(
        repository: BillReminderRepository(),
        reminderService: BillReminderService()
    ))
}
