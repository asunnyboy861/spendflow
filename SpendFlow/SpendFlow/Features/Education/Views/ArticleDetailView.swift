import SwiftUI

struct ArticleDetailView: View {
    let article: EducationArticle
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.l) {
                headerSection
                
                contentSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: article.icon)
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: article.color))
                .frame(width: 80, height: 80)
                .background(Color(hex: article.color).opacity(0.15))
                .cornerRadius(20)
            
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(article.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(article.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: DesignTokens.Spacing.m) {
                Label(article.category.rawValue, systemImage: article.category.icon)
                    .font(.caption)
                    .foregroundStyle(Color(hex: article.category.color))
                
                Label("\(article.readTime) min read", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Text(article.content)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(article: EducationArticle.sampleArticles[0])
    }
}
