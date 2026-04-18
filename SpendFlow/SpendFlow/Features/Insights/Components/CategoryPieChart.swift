import SwiftUI
import Charts

struct CategoryPieChart: View {
    let categorySpending: [CategorySpending]
    @State private var selectedAmount: Double?
    
    private var selectedCategory: CategorySpending? {
        guard let amount = selectedAmount else { return nil }
        return categorySpending.first { $0.amount == amount }
    }
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            if #available(iOS 16, *) {
                chartView
            } else {
                categoryListView
            }
        }
        .cardStyle()
    }
    
    @available(iOS 16, *)
    private var chartView: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Text("Spending by Category")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Chart(categorySpending) { spending in
                SectorMark(
                    angle: .value("Amount", spending.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .cornerRadius(4)
                .foregroundStyle(Color(hex: spending.color))
                .opacity(selectedCategory?.id == spending.id ? 1.0 : 0.7)
            }
            .frame(height: 200)
            .chartAngleSelection(value: $selectedAmount)
            
            if let selected = selectedCategory {
                selectedCategoryDetail(selected)
            }
            
            categoryLegend
        }
    }
    
    private var categoryListView: some View {
        VStack(spacing: DesignTokens.Spacing.s) {
            Text("Spending by Category")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(categorySpending) { spending in
                HStack {
                    Circle()
                        .fill(Color(hex: spending.color))
                        .frame(width: 12, height: 12)
                    
                    Text(spending.categoryName)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(spending.amount.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func selectedCategoryDetail(_ category: CategorySpending) -> some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(category.categoryName)
                .font(.headline)
            
            Text(category.amount.currencyFormatted)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(Int(category.percentage))% of total")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(DesignTokens.Spacing.s)
        .background(Color(hex: category.color).opacity(0.1))
        .cornerRadius(8)
    }
    
    private var categoryLegend: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.s) {
            ForEach(categorySpending.prefix(6)) { spending in
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Circle()
                        .fill(Color(hex: spending.color))
                        .frame(width: 8, height: 8)
                    
                    Text(spending.categoryName)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    let sampleData = [
        CategorySpending(categoryName: "Food & Dining", amount: 450.0, percentage: 30, color: "FF6B6B", transactionCount: 15),
        CategorySpending(categoryName: "Transportation", amount: 300.0, percentage: 20, color: "4ECDC4", transactionCount: 10),
        CategorySpending(categoryName: "Shopping", amount: 250.0, percentage: 17, color: "45B7D1", transactionCount: 8),
        CategorySpending(categoryName: "Entertainment", amount: 200.0, percentage: 13, color: "96CEB4", transactionCount: 5),
        CategorySpending(categoryName: "Healthcare", amount: 150.0, percentage: 10, color: "FFEAA7", transactionCount: 3),
        CategorySpending(categoryName: "Other", amount: 150.0, percentage: 10, color: "95A5A6", transactionCount: 7)
    ]
    
    return CategoryPieChart(categorySpending: sampleData)
        .padding()
}
