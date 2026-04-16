import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: Category
    let categories: [Category]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.s) {
                ForEach(categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory.id == category.id
                    ) {
                        selectedCategory = category
                        HapticFeedback.light()
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.xs)
        }
    }
}

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Color(hex: category.color).opacity(0.2)
                    : Color(.systemGray6)
            )
            .foregroundColor(isSelected ? Color(hex: category.color) : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color(hex: category.color) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
