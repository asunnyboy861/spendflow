import Charts
import SwiftUI

struct NetWorthTrendChart: View {
    let entries: [NetWorthEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("Net Worth Over Time")
                .font(.headline)
            
            if entries.count < 2 {
                Text("Add at least 2 entries to see trends")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                if #available(iOS 16, *) {
                    chartContent
                } else {
                    listView
                }
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    @available(iOS 16, *)
    private var chartContent: some View {
        Chart(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Net Worth", entry.netWorth)
            )
            .foregroundStyle(.accentBlue)
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Date", entry.date),
                y: .value("Net Worth", entry.netWorth)
            )
            .foregroundStyle(.accentBlue.opacity(0.1))
            .interpolationMethod(.catmullRom)
        }
        .frame(height: 200)
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let val = value.as(Double.self) {
                        Text(val.currencyFormatted)
                            .font(.caption2)
                    }
                }
            }
        }
    }
    
    private var listView: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(entries.reversed()) { entry in
                HStack {
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(entry.netWorth.currencyFormatted)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

#Preview {
    let entries = [
        NetWorthEntry(date: Date().addingTimeInterval(-86400 * 90), assets: [AssetItem(name: "Checking", category: .checking, amount: 5000)], liabilities: [LiabilityItem(name: "Credit Card", category: .creditCard, amount: 2000)]),
        NetWorthEntry(date: Date().addingTimeInterval(-86400 * 60), assets: [AssetItem(name: "Checking", category: .checking, amount: 5500)], liabilities: [LiabilityItem(name: "Credit Card", category: .creditCard, amount: 1800)]),
        NetWorthEntry(date: Date().addingTimeInterval(-86400 * 30), assets: [AssetItem(name: "Checking", category: .checking, amount: 6000)], liabilities: [LiabilityItem(name: "Credit Card", category: .creditCard, amount: 1500)])
    ]
    
    NetWorthTrendChart(entries: entries)
}
