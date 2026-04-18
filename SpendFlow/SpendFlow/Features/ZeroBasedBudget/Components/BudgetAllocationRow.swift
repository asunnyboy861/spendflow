import SwiftUI

struct BudgetAllocationRow: View {
    let allocation: BudgetAllocation
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.s) {
            HStack {
                Text(allocation.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if allocation.isOverBudget {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.expenseRed)
                        .font(.caption)
                }
                
                Text(allocation.remaining.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(allocation.remaining >= 0 ? .incomeGreen : .expenseRed)
            }
            
            HStack(spacing: DesignTokens.Spacing.m) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Budgeted")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(allocation.allocated.currencyFormatted)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spent")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(allocation.spent.currencyFormatted)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(allocation.isOverBudget ? .expenseRed : .primary)
                }
                
                Spacer()
                
                Text("\(Int(min(allocation.percentage, 100)))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(allocation.isOverBudget ? .expenseRed : .secondary)
            }
            
            ProgressView(value: min(allocation.percentage, 100), total: 100)
                .tint(allocation.isOverBudget ? .expenseRed : .incomeGreen)
                .frame(height: 4)
        }
        .padding(DesignTokens.Spacing.s)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 12) {
        BudgetAllocationRow(allocation: BudgetAllocation(category: "Food & Dining", allocated: 500, spent: 350))
        BudgetAllocationRow(allocation: BudgetAllocation(category: "Transportation", allocated: 300, spent: 320))
        BudgetAllocationRow(allocation: BudgetAllocation(category: "Entertainment", allocated: 200, spent: 150))
    }
    .padding()
}
