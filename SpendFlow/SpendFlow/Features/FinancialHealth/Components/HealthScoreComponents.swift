import SwiftUI

struct HealthScoreRing: View {
    let score: Int
    let maxScore: Int
    let color: String
    let grade: String
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: color).opacity(0.2), lineWidth: 12)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(Color(hex: color), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: animatedProgress)
            
            VStack(spacing: 2) {
                Text(grade)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: color))
                
                Text("\(score)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 120, height: 120)
        .onAppear {
            animatedProgress = Double(score) / Double(maxScore)
        }
    }
}

struct DimensionScoreBar: View {
    let dimension: HealthDimension
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Image(systemName: dimension.icon)
                    .foregroundStyle(Color(hex: dimension.color))
                    .font(.caption)
                
                Text(dimension.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(dimension.grade)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: dimension.color))
                
                Text("\(dimension.score)/\(dimension.maxScore)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: animatedProgress, total: 1.0)
                .tint(Color(hex: dimension.color))
                .frame(height: 6)
                .animation(.easeOut(duration: 0.8), value: animatedProgress)
        }
        .onAppear {
            animatedProgress = dimension.percentage / 100
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HealthScoreRing(score: 85, maxScore: 100, color: "34C759", grade: "B")
        
        DimensionScoreBar(dimension: HealthDimension(
            name: "Savings Rate",
            icon: "piggybank",
            score: 17,
            maxScore: 20,
            color: "34C759",
            tips: ["Good!"]
        ))
    }
    .padding()
}
