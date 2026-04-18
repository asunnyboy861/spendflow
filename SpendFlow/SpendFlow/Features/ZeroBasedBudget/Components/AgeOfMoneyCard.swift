import SwiftUI

struct AgeOfMoneyCard: View {
    let ageOfMoney: AgeOfMoney?
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            HStack {
                Text("Age of Money")
                    .font(.headline)
                
                Spacer()
                
                if let age = ageOfMoney {
                    Image(systemName: age.icon)
                        .foregroundStyle(Color(hex: age.color))
                }
            }
            
            if let age = ageOfMoney {
                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text(age.displayText)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: age.color))
                    
                    Text(age.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text("--")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text("Add income transactions to calculate")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
}

#Preview {
    VStack(spacing: 12) {
        AgeOfMoneyCard(ageOfMoney: AgeOfMoney(days: 23, trend: .increasing))
        AgeOfMoneyCard(ageOfMoney: AgeOfMoney(days: 15, trend: .stable))
        AgeOfMoneyCard(ageOfMoney: AgeOfMoney(days: 8, trend: .decreasing))
        AgeOfMoneyCard(ageOfMoney: nil)
    }
    .padding()
}
