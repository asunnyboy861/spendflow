import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    private var categoryIcon: String {
        Category.commonCategories.first { $0.name == transaction.category }?.icon
            ?? Category.incomeCategories.first { $0.name == transaction.category }?.icon
            ?? "circle.fill"
    }

    private var categoryColor: Color {
        let hex = Category.commonCategories.first { $0.name == transaction.category }?.color
            ?? Category.incomeCategories.first { $0.name == transaction.category }?.color
            ?? "8E8E93"
        return Color(hex: hex)
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: categoryIcon)
                .font(.title3)
                .foregroundStyle(categoryColor)
                .frame(width: 40, height: 40)
                .background(categoryColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category)
                    .font(.subheadline.bold())
                if let note = transaction.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type == .expense ? "-" : "+")\(transaction.amount.currencyFormatted)")
                    .font(.subheadline.bold())
                    .foregroundStyle(transaction.type == .expense ? Color.expenseRed : Color.incomeGreen)
                Text(transaction.date.timeFormat)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.s)
        .contentShape(Rectangle())
    }
}
