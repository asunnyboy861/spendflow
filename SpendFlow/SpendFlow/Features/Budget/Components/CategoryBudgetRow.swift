import SwiftUI

struct CategoryBudgetRow: View {
    let spending: BudgetOverviewViewModel.CategorySpending

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: spending.icon)
                .font(.title3)
                .foregroundStyle(Color(hex: spending.color))
                .frame(width: 40, height: 40)
                .background(Color(hex: spending.color).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(spending.category)
                    .font(.subheadline.bold())

                if spending.budget > 0 {
                    ProgressBar(
                        progress: spending.progress,
                        color: spendingColor,
                        height: 6
                    )
                }

                HStack {
                    Text("Spent \(spending.spent.currencyFormatted)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if spending.budget > 0 {
                        Text("of \(spending.budget.currencyFormatted)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            if spending.budget > 0 {
                Text("\(Int(spending.progress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(spendingColor)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    private var spendingColor: Color {
        if spending.progress < 0.5 { return .incomeGreen }
        if spending.progress < 0.8 { return .warningOrange }
        return .expenseRed
    }
}
