import SwiftUI

struct AssetLiabilityRow: View {
    let name: String
    let amount: Double
    let icon: String
    let color: String
    let isAsset: Bool
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color(hex: color))
                .frame(width: 32, height: 32)
                .background(Color(hex: color).opacity(0.15))
                .cornerRadius(8)
            
            Text(name)
                .font(.subheadline)
            
            Spacer()
            
            Text(amount.currencyFormatted)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isAsset ? .incomeGreen : .expenseRed)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }
}

#Preview {
    VStack(spacing: 4) {
        AssetLiabilityRow(name: "Chase Checking", amount: 5432, icon: "banknote", color: "007AFF", isAsset: true)
        AssetLiabilityRow(name: "401(k)", amount: 85000, icon: "building.columns", color: "FF9500", isAsset: true)
        AssetLiabilityRow(name: "Mortgage", amount: 250000, icon: "house.fill", color: "E74C3C", isAsset: false)
    }
    .padding()
}
