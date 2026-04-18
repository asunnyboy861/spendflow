import SwiftUI

struct FinancialHealthView: View {
    @StateObject private var viewModel: FinancialHealthViewModel
    
    init(
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        _viewModel = StateObject(wrappedValue: FinancialHealthViewModel(
            transactionRepository: transactionRepository,
            budgetRepository: budgetRepository
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.l) {
                if let score = viewModel.healthScore {
                    overallScoreCard(score)
                    dimensionsSection(score)
                    tipsSection(score)
                } else {
                    emptyStateView
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Financial Health")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            viewModel.calculateScore()
        }
    }
    
    private func overallScoreCard(_ score: FinancialHealthScore) -> some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            HealthScoreRing(
                score: score.overallScore,
                maxScore: 100,
                color: score.scoreColor,
                grade: score.grade.rawValue
            )
            
            Text(score.scoreDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private func dimensionsSection(_ score: FinancialHealthScore) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("Score Breakdown")
                .font(.headline)
            
            ForEach(score.dimensions) { dimension in
                DimensionScoreBar(dimension: dimension)
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private func tipsSection(_ score: FinancialHealthScore) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("Improvement Tips")
                .font(.headline)
            
            let weakDimensions = score.dimensions.filter { $0.percentage < 75 }
            
            if weakDimensions.isEmpty {
                HStack(spacing: DesignTokens.Spacing.s) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.incomeGreen)
                    Text("You're doing great! Keep up the good work.")
                        .font(.subheadline)
                }
            } else {
                ForEach(weakDimensions) { dimension in
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        HStack {
                            Image(systemName: dimension.icon)
                                .foregroundStyle(Color(hex: dimension.color))
                            Text(dimension.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        ForEach(dimension.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: DesignTokens.Spacing.s) {
                                Text("•")
                                    .foregroundStyle(.secondary)
                                Text(tip)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, DesignTokens.Spacing.xs)
                }
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("Calculate Your Score")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add transactions and budgets to calculate your financial health score")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.xl)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        FinancialHealthView(
            transactionRepository: TransactionRepositoryImpl(),
            budgetRepository: BudgetRepositoryImpl()
        )
    }
}
