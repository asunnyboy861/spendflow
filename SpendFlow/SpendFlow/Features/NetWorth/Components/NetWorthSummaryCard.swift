import SwiftUI

struct NetWorthSummaryCard: View {
    let netWorth: Double
    let totalAssets: Double
    let totalLiabilities: Double
    let trend: NetWorthTrend
    let change: Double
    let changePercentage: Double
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            HStack {
                Text("Net Worth")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .foregroundStyle(Color(hex: trend.color))
            }
            
            Text(netWorth.currencyFormatted)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(netWorth >= 0 ? Color.primary : Color.expenseRed)
            
            if change != 0 {
                HStack(spacing: 4) {
                    Text(change >= 0 ? "+" : "")
                    +
                    Text(change.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("(\(String(format: "%.1f", abs(changePercentage)))%)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(Color(hex: trend.color))
            }
            
            Divider()
            
            HStack(spacing: DesignTokens.Spacing.l) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(.incomeGreen)
                            .font(.caption)
                        Text("Assets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(totalAssets.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.incomeGreen)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(.expenseRed)
                            .font(.caption)
                        Text("Liabilities")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(totalLiabilities.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.expenseRed)
                }
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
}

#Preview {
    NetWorthSummaryCard(
        netWorth: 45000,
        totalAssets: 120000,
        totalLiabilities: 75000,
        trend: .increasing,
        change: 2500,
        changePercentage: 5.9
    )
}
