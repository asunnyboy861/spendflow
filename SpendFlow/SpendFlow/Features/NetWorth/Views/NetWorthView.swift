import SwiftUI

struct NetWorthView: View {
    @StateObject private var viewModel: NetWorthViewModel
    @State private var showAddEntry = false
    
    init(repository: NetWorthRepository = NetWorthRepository()) {
        _viewModel = StateObject(wrappedValue: NetWorthViewModel(repository: repository))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.l) {
                NetWorthSummaryCard(
                    netWorth: viewModel.currentNetWorth,
                    totalAssets: viewModel.totalAssets,
                    totalLiabilities: viewModel.totalLiabilities,
                    trend: viewModel.netWorthTrend,
                    change: viewModel.netWorthChange,
                    changePercentage: viewModel.netWorthChangePercentage
                )
                
                NetWorthTrendChart(entries: viewModel.trendEntries)
                
                if let entry = viewModel.currentEntry {
                    assetsSection(entry)
                    liabilitiesSection(entry)
                } else {
                    emptyStateView
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Net Worth")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddEntry) {
            AddNetWorthEntryView(viewModel: viewModel)
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    private func assetsSection(_ entry: NetWorthEntry) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundStyle(.incomeGreen)
                Text("Assets")
                    .font(.headline)
                
                Spacer()
                
                Text(entry.totalAssets.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.incomeGreen)
            }
            
            ForEach(entry.assets) { asset in
                AssetLiabilityRow(
                    name: asset.name,
                    amount: asset.amount,
                    icon: asset.category.icon,
                    color: asset.category.color,
                    isAsset: true
                )
            }
        }
        .padding(DesignTokens.Spacing.m)
        .cardStyle()
    }
    
    private func liabilitiesSection(_ entry: NetWorthEntry) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(.expenseRed)
                Text("Liabilities")
                    .font(.headline)
                
                Spacer()
                
                Text(entry.totalLiabilities.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.expenseRed)
            }
            
            ForEach(entry.liabilities) { liability in
                AssetLiabilityRow(
                    name: liability.name,
                    amount: liability.amount,
                    icon: liability.category.icon,
                    color: liability.category.color,
                    isAsset: false
                )
            }
        }
        .padding(DesignTokens.Spacing.m)
        .cardStyle()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Track Your Net Worth")
                .font(.headline)
            
            Text("Add your assets and liabilities to track your financial progress over time")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HapticButton("Get Started", style: .primary) {
                showAddEntry = true
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        NetWorthView()
    }
}
