import SwiftUI

struct RemainingBudgetCard: View {
    let remaining: Double
    let total: Double
    let progress: Double
    let period: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Text("Remaining \(period)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text(remaining.currencyFormatted)
                .font(.system(size: DesignTokens.FontSize.displayLarge * 0.55, weight: .bold, design: .rounded))
                .foregroundStyle(progressColor)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: remaining)

            VStack(spacing: DesignTokens.Spacing.xs) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(progressColor.gradient)
                            .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                            .animation(.spring(response: 0.5), value: progress)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("Spent \(total.currencyFormatted)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(progressColor)
                }
            }
        }
        .cardStyle(padding: DesignTokens.Spacing.l)
    }

    private var progressColor: Color {
        if progress < 0.5 { return .incomeGreen }
        if progress < 0.8 { return .warningOrange }
        return .expenseRed
    }
}
