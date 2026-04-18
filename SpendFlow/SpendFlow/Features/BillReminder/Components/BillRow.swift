import SwiftUI

struct BillRow: View {
    let bill: BillReminder
    let onMarkPaid: () -> Void
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: bill.status.icon)
                .font(.title3)
                .foregroundStyle(Color(hex: bill.status.color))
                .frame(width: 36, height: 36)
                .background(Color(hex: bill.status.color).opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bill.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(bill.isPaid)
                
                HStack(spacing: 4) {
                    Text(bill.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if bill.isRecurring {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(bill.amount.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(bill.status.displayText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: bill.status.color))
            }
            
            if !bill.isPaid {
                Button {
                    onMarkPaid()
                } label: {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.incomeGreen)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignTokens.Spacing.s)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 8) {
        BillRow(bill: BillReminder(name: "Rent", amount: 1500, dueDate: Date().addingTimeInterval(86400 * 3), category: "Housing"), onMarkPaid: {})
        BillRow(bill: BillReminder(name: "Netflix", amount: 15.99, dueDate: Date().addingTimeInterval(86400 * 7), category: "Entertainment", isRecurring: true), onMarkPaid: {})
        BillRow(bill: BillReminder(name: "Electric Bill", amount: 85, dueDate: Date().addingTimeInterval(-86400 * 2), category: "Utilities"), onMarkPaid: {})
    }
    .padding()
}
