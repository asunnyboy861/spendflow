import SwiftUI

struct SuggestionRow: View {
    let suggestion: CategorySuggestion
    let isSelected: Bool
    let onTap: () -> Void
    
    private var categoryColor: Color {
        Color(hex: suggestion.category.color)
    }
    
    private var confidenceText: String {
        "\(Int(suggestion.confidence * 100))% match"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.m) {
                iconView
                
                textContent
                
                Spacer()
                
                selectionIndicator
            }
            .padding(.horizontal, DesignTokens.Spacing.m)
            .padding(.vertical, DesignTokens.Spacing.s)
            .background(backgroundView)
            .overlay(borderOverlay)
        }
        .buttonStyle(.plain)
    }
    
    private var iconView: some View {
        Image(systemName: suggestion.category.icon)
            .font(.title3)
            .foregroundStyle(categoryColor)
            .frame(width: 32, height: 32)
            .background(categoryColor.opacity(0.15))
            .cornerRadius(8)
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(suggestion.category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            HStack(spacing: 4) {
                Text(suggestion.source.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Text(confidenceText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var selectionIndicator: some View {
        Group {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
    }
}

#Preview {
    VStack(spacing: 12) {
        SuggestionRow(
            suggestion: CategorySuggestion(
                category: Category(name: "Food & Dining", icon: "fork.knife", color: "FF9500"),
                confidence: 0.95,
                source: .history
            ),
            isSelected: true,
            onTap: {}
        )
        
        SuggestionRow(
            suggestion: CategorySuggestion(
                category: Category(name: "Transportation", icon: "car.fill", color: "5856D6"),
                confidence: 0.85,
                source: .rule
            ),
            isSelected: false,
            onTap: {}
        )
    }
    .padding()
}
