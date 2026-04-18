import SwiftUI
import Charts

struct MonthlyTrendChart: View {
    let monthlyData: [MonthlyData]
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Text("Monthly Trend")
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
        Chart(monthlyData) { data in
            LineMark(
                x: .value("Month", data.month, unit: .month),
                y: .value("Amount", data.income)
            )
            .foregroundStyle(.incomeGreen)
            .symbol(by: .value("Type", "Income"))
            
            LineMark(
                x: .value("Month", data.month, unit: .month),
                y: .value("Amount", data.expense)
            )
            .foregroundStyle(.expenseRed)
            .symbol(by: .value("Type", "Expense"))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
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
            ForEach(monthlyData) { data in
                HStack {
                    Text(formatMonth(data.month))
                        .font(.subheadline)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("Income:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(data.income.currencyFormatted)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.incomeGreen)
                        }
                        
                        HStack(spacing: 4) {
                            Text("Expense:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(data.expense.currencyFormatted)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.expenseRed)
                        }
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
            }
        }
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    let calendar = Calendar.current
    let now = Date()
    
    let sampleData = (0..<6).compactMap { i -> MonthlyData? in
        guard let month = calendar.date(byAdding: .month, value: -i, to: now) else { return nil }
        return MonthlyData(
            month: month,
            income: Double.random(in: 3000...5000),
            expense: Double.random(in: 2000...4000),
            savings: Double.random(in: 500...1500)
        )
    }.reversed()
    
    return MonthlyTrendChart(monthlyData: Array(sampleData))
        .padding()
}
