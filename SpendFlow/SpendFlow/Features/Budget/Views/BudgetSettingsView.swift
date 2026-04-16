import SwiftUI

struct BudgetSettingsView: View {
    @State private var monthlyBudget: String = ""
    @State private var dailyBudget: String = ""
    private let budgetRepository: BudgetRepository

    init(budgetRepository: BudgetRepository) {
        self.budgetRepository = budgetRepository
    }

    var body: some View {
        Form {
            Section("Monthly Budget") {
                HStack {
                    Text("$")
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $monthlyBudget)
                        .keyboardType(.decimalPad)
                }
            }

            Section("Daily Budget") {
                HStack {
                    Text("$")
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $dailyBudget)
                        .keyboardType(.decimalPad)
                }
            }

            Section {
                HapticButton("Save Budget") {
                    saveBudgets()
                }
            }
        }
        .navigationTitle("Budget Settings")
        .onAppear {
            loadBudgets()
        }
    }

    private func loadBudgets() {
        if let monthly = budgetRepository.fetchBudget(for: .monthly) {
            monthlyBudget = String(format: "%.0f", monthly.amount)
        }
        if let daily = budgetRepository.fetchBudget(for: .daily) {
            dailyBudget = String(format: "%.0f", daily.amount)
        }
    }

    private func saveBudgets() {
        if let amount = Double(monthlyBudget), amount > 0 {
            if let existing = budgetRepository.fetchBudget(for: .monthly) {
                var updated = existing
                updated.amount = amount
                try? budgetRepository.update(updated)
            } else {
                let budget = Budget(amount: amount, period: .monthly)
                try? budgetRepository.save(budget)
            }
        }

        if let amount = Double(dailyBudget), amount > 0 {
            if let existing = budgetRepository.fetchBudget(for: .daily) {
                var updated = existing
                updated.amount = amount
                try? budgetRepository.update(updated)
            } else {
                let budget = Budget(amount: amount, period: .daily)
                try? budgetRepository.save(budget)
            }
        }

        HapticFeedback.success()
    }
}
