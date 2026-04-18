import SwiftUI

struct CategorySuggestionView: View {
    @StateObject private var viewModel: CategorySuggestionViewModel
    @Binding var selectedCategory: Category?
    let description: String
    let amount: Double
    let onCategorySelected: (Category) -> Void
    
    init(
        suggestionService: CategorySuggestionService,
        selectedCategory: Binding<Category?>,
        description: String,
        amount: Double,
        onCategorySelected: @escaping (Category) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: CategorySuggestionViewModel(
            suggestionService: suggestionService
        ))
        self._selectedCategory = selectedCategory
        self.description = description
        self.amount = amount
        self.onCategorySelected = onCategorySelected
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            header
            
            if viewModel.isLoading {
                loadingView
            } else if viewModel.suggestions.isEmpty {
                emptyView
            } else {
                suggestionsList
            }
        }
        .onAppear {
            viewModel.getSuggestions(for: description, amount: amount)
        }
        .onChange(of: viewModel.selectedCategory) { _, newCategory in
            selectedCategory = newCategory
            if let category = newCategory {
                onCategorySelected(category)
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Suggested Categories")
                .font(.headline)
            
            Text("Based on your transaction description")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
            Spacer()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: DesignTokens.Spacing.s) {
            Image(systemName: "tag.slash")
                .font(.title)
                .foregroundStyle(.secondary)
            
            Text("No suggestions available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    private var suggestionsList: some View {
        VStack(spacing: DesignTokens.Spacing.s) {
            ForEach(viewModel.suggestions) { suggestion in
                SuggestionRow(
                    suggestion: suggestion,
                    isSelected: viewModel.selectedCategory?.id == suggestion.category.id
                ) {
                    viewModel.selectCategory(suggestion.category)
                }
            }
        }
    }
}

#Preview {
    let ruleSuggester = RuleBasedSuggester()
    let learningService = CategoryLearningService()
    let suggestionService = CompositeCategorySuggestionService(
        ruleBasedSuggester: ruleSuggester,
        learningService: learningService
    )
    
    CategorySuggestionView(
        suggestionService: suggestionService,
        selectedCategory: .constant(nil),
        description: "Starbucks Coffee",
        amount: 5.50,
        onCategorySelected: { _ in }
    )
    .padding()
}
