import SwiftUI

struct ArticleCard: View {
    let article: EducationArticle
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Image(systemName: article.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: article.color))
                .frame(width: 44, height: 44)
                .background(Color(hex: article.color).opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(article.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: DesignTokens.Spacing.s) {
                    Text(article.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: article.category.color).opacity(0.15))
                        .cornerRadius(4)
                        .foregroundStyle(Color(hex: article.category.color))
                    
                    Text("\(article.readTime) min read")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(DesignTokens.Spacing.m)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 8) {
        ArticleCard(article: EducationArticle.sampleArticles[0])
        ArticleCard(article: EducationArticle.sampleArticles[1])
    }
    .padding()
}
