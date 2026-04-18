import SwiftUI

struct EducationView: View {
    @State private var selectedCategory: EducationCategory?
    @State private var searchText = ""
    
    private let articles = EducationArticle.sampleArticles
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.l) {
                featuredSection
                
                categoryFilter
                
                articlesSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search articles")
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text("Featured")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.m) {
                    ForEach(articles.filter { $0.isFeatured }) { article in
                        NavigationLink {
                            ArticleDetailView(article: article)
                        } label: {
                            FeaturedArticleCard(article: article)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.s) {
                CategoryPill(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    color: "8E8E93",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(EducationCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    private var articlesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text(selectedCategory == nil ? "All Articles" : selectedCategory!.rawValue)
                .font(.headline)
            
            ForEach(filteredArticles) { article in
                NavigationLink {
                    ArticleDetailView(article: article)
                } label: {
                    ArticleCard(article: article)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var filteredArticles: [EducationArticle] {
        var result = articles
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
}

struct FeaturedArticleCard: View {
    let article: EducationArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            Image(systemName: article.icon)
                .font(.title)
                .foregroundStyle(Color(hex: article.color))
            
            Text(article.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            Text(article.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            
            HStack {
                Text(article.category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(Color(hex: article.category.color))
                
                Spacer()
                
                Text("\(article.readTime) min")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 180)
        .padding(DesignTokens.Spacing.m)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct CategoryPill: View {
    let title: String
    let icon: String
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color(hex: color) : Color(hex: color).opacity(0.15))
            .foregroundStyle(isSelected ? .white : Color(hex: color))
            .cornerRadius(20)
        }
    }
}

#Preview {
    NavigationStack {
        EducationView()
    }
}
