import SwiftUI
import Charts

struct BudgetComparisonChart: View {
    let budgetComparison: [BudgetComparison]
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Text("Budget vs Actual")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if #available(iOS 16, *) {
                chartView
            } else {
                listView
            }
        }
        .cardStyle()
    }
    
    @available(iOS 16, *)
    private var chartView: some View {
        Chart(budgetComparison) { comparison in
            BarMark(
                x: .value("Category", comparison.categoryName),
                y: .value("Amount", comparison.budgeted)
            )
            .foregroundStyle(.accentBlue.opacity(0.5))
            .position(by: .value("Type", "Budget"))
            
            BarMark(
                x: .value("Category", comparison.categoryName),
                y: .value("Amount", comparison.spent)
            )
            .foregroundStyle(comparison.spent > comparison.budgeted ? .expenseRed : .incomeGreen)
            .position(by: .value("Type", "Actual"))
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartLegend(position: .top, alignment: .leading)
        .frame(height: 200)
    }
    
    private var listView: some View {
        VStack(spacing: DesignTokens.Spacing.s) {
            ForEach(budgetComparison) { comparison in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack {
                        Text(comparison.categoryName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        if comparison.spent > comparison.budgeted {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.warningOrange)
                                .font(.caption)
                        }
                    }
                    
                    HStack(spacing: DesignTokens.Spacing.m) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Budget")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(comparison.budgeted.currencyFormatted)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Actual")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(comparison.spent.currencyFormatted)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(comparison.spent > comparison.budgeted ? .expenseRed : .incomeGreen)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Remaining")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(comparison.remaining.currencyFormatted)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(comparison.remaining >= 0 ? .incomeGreen : .expenseRed)
                        }
                    }
                    
                    ProgressView(value: min(comparison.percentage, 100), total: 100)
                        .tint(comparison.percentage > 100 ? .expenseRed : .incomeGreen)
                        .frame(height: 4)
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
            }
        }
    }
}

#Preview {
    let sampleData = [
        BudgetComparison(categoryName: "Food & Dining", budgeted: 500, spent: 450),
        BudgetComparison(categoryName: "Transportation", budgeted: 300, spent: 320),
        BudgetComparison(categoryName: "Shopping", budgeted: 200, spent: 180),
        BudgetComparison(categoryName: "Entertainment", budgeted: 150, spent: 200)
    ]
    
    return BudgetComparisonChart(budgetComparison: sampleData)
        .padding()
}
