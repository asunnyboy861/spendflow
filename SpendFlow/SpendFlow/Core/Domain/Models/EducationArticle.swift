import Foundation

struct EducationArticle: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: EducationCategory
    let content: String
    let readTime: Int
    let icon: String
    let color: String
    let isFeatured: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        category: EducationCategory,
        content: String,
        readTime: Int,
        icon: String,
        color: String,
        isFeatured: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.content = content
        self.readTime = readTime
        self.icon = icon
        self.color = color
        self.isFeatured = isFeatured
    }
}

enum EducationCategory: String, CaseIterable {
    case budgeting = "Budgeting"
    case saving = "Saving"
    case investing = "Investing"
    case debt = "Debt Management"
    case taxes = "Taxes"
    case retirement = "Retirement"
    
    var icon: String {
        switch self {
        case .budgeting: return "chart.pie.fill"
        case .saving: return "piggybank"
        case .investing: return "chart.line.uptrend.xyaxis"
        case .debt: return "creditcard"
        case .taxes: return "doc.text.fill"
        case .retirement: return "building.columns.fill"
        }
    }
    
    var color: String {
        switch self {
        case .budgeting: return "007AFF"
        case .saving: return "34C759"
        case .investing: return "5856D6"
        case .debt: return "FF9500"
        case .taxes: return "FF2D55"
        case .retirement: return "5AC8FA"
        }
    }
}

extension EducationArticle {
    static let sampleArticles: [EducationArticle] = [
        EducationArticle(
            title: "The 50/30/20 Rule",
            subtitle: "A simple framework for managing your money",
            category: .budgeting,
            content: """
The 50/30/20 rule is a simple budgeting framework that divides your after-tax income into three categories:

**50% for Needs**
This includes essential expenses like:
- Rent or mortgage payments
- Groceries
- Utilities (electricity, water, gas)
- Health insurance
- Minimum debt payments
- Transportation

**30% for Wants**
This covers non-essential spending:
- Dining out
- Entertainment
- Shopping
- Subscriptions
- Travel
- Hobbies

**20% for Savings & Debt Repayment**
This goes toward your financial future:
- Emergency fund
- Retirement contributions
- Extra debt payments
- Investment accounts
- Savings goals

**Tips for Success:**
1. Track your spending for a month to see where you stand
2. Adjust percentages based on your situation (e.g., 60/20/20 in high-cost areas)
3. Automate your savings to ensure the 20% happens
4. Review and adjust quarterly
""",
            readTime: 5,
            icon: "chart.pie.fill",
            color: "007AFF",
            isFeatured: true
        ),
        EducationArticle(
            title: "Building an Emergency Fund",
            subtitle: "Your financial safety net starts here",
            category: .saving,
            content: """
An emergency fund is money set aside for unexpected expenses. Here's how to build one:

**Why You Need One**
- Covers unexpected medical bills
- Protects against job loss
- Prevents high-interest debt
- Provides peace of mind

**How Much to Save**
- Starter fund: $1,000
- Full fund: 3-6 months of expenses
- Consider your job stability and health

**Steps to Build Your Fund**
1. Start with a goal of $1,000
2. Set up automatic transfers
3. Use a high-yield savings account
4. Cut unnecessary expenses temporarily
5. Save windfalls (tax refunds, bonuses)

**Where to Keep It**
- High-yield savings account
- Money market account
- Don't invest your emergency fund

**When to Use It**
- Medical emergencies
- Car repairs
- Home repairs
- Job loss
- NOT for sales, vacations, or wants
""",
            readTime: 4,
            icon: "shield.fill",
            color: "34C759",
            isFeatured: true
        ),
        EducationArticle(
            title: "Understanding Credit Scores",
            subtitle: "What affects your score and how to improve it",
            category: .debt,
            content: """
Your credit score is a number that represents your creditworthiness. Here's what you need to know:

**Score Ranges**
- 800-850: Excellent
- 740-799: Very Good
- 670-739: Good
- 580-669: Fair
- 300-579: Poor

**Factors That Affect Your Score**
1. Payment History (35%) - Pay on time, every time
2. Credit Utilization (30%) - Keep below 30%
3. Length of Credit History (15%) - Older accounts help
4. Credit Mix (10%) - Variety of account types
5. New Credit (10%) - Limit hard inquiries

**How to Improve Your Score**
- Pay all bills on time
- Keep credit card balances low
- Don't close old accounts
- Limit new credit applications
- Check your report for errors
- Use credit monitoring services

**Common Myths**
- Checking your score doesn't hurt it
- Closing cards can lower your score
- You don't need to carry a balance
- Income doesn't directly affect your score
""",
            readTime: 6,
            icon: "number.circle.fill",
            color: "FF9500"
        ),
        EducationArticle(
            title: "Getting Started with Investing",
            subtitle: "Beginner's guide to growing your wealth",
            category: .investing,
            content: """
Investing is essential for long-term wealth building. Here's how to start:

**Before You Invest**
1. Build an emergency fund first
2. Pay off high-interest debt
3. Understand your risk tolerance
4. Define your investment goals

**Types of Investments**
- **Stocks**: Own shares of companies
- **Bonds**: Lend money for fixed returns
- **ETFs**: Basket of stocks or bonds
- **Index Funds**: Track market indexes
- **Real Estate**: Property investments

**Getting Started**
1. Open a brokerage account
2. Start with index funds for diversification
3. Use dollar-cost averaging
4. Reinvest dividends
5. Keep fees low

**Key Principles**
- Start early (compound interest is powerful)
- Diversify your portfolio
- Invest consistently
- Don't try to time the market
- Think long-term (5+ years)

**Retirement Accounts**
- 401(k): Employer-sponsored, often with match
- IRA: Individual retirement account
- Roth IRA: Tax-free growth
""",
            readTime: 7,
            icon: "chart.line.uptrend.xyaxis",
            color: "5856D6"
        ),
        EducationArticle(
            title: "Tax Basics for Americans",
            subtitle: "Understanding your tax obligations",
            category: .taxes,
            content: """
Understanding taxes helps you keep more of your money:

**Tax Brackets (2024)**
The U.S. uses a progressive tax system with seven brackets from 10% to 37%.

**Key Tax Documents**
- W-2: Wage and tax statement
- 1099: Miscellaneous income
- 1098: Mortgage interest
- 1040: Individual tax return

**Common Deductions**
- Standard deduction ($14,600 single / $29,200 married)
- Mortgage interest
- State and local taxes (SALT, up to $10,000)
- Charitable contributions
- Student loan interest (up to $2,500)

**Tax Tips**
1. Adjust your W-4 withholdings
2. Maximize retirement contributions
3. Use tax-advantaged accounts (HSA, 529)
4. Track deductible expenses year-round
5. File on time or request an extension

**Important Dates**
- January: Receive tax documents
- April 15: Tax filing deadline
- October 15: Extension deadline
""",
            readTime: 5,
            icon: "doc.text.fill",
            color: "FF2D55"
        ),
        EducationArticle(
            title: "Retirement Planning 101",
            subtitle: "Start planning for your future today",
            category: .retirement,
            content: """
It's never too early to start planning for retirement:

**How Much Do You Need?**
- General rule: 80% of pre-retirement income
- Use the 4% rule for withdrawal
- Consider inflation (3% average annually)

**Retirement Accounts**
- **401(k)**: Up to $23,000/year (2024)
- **Traditional IRA**: Up to $7,000/year
- **Roth IRA**: Tax-free growth, same limits
- **HSA**: Triple tax advantage

**Employer Match**
- Always get the full employer match
- It's free money (often 3-6% of salary)
- Vesting schedules may apply

**Investment Strategy by Age**
- 20s-30s: Aggressive (80-90% stocks)
- 40s-50s: Moderate (60-70% stocks)
- 60s+: Conservative (40-50% stocks)

**Action Steps**
1. Calculate your retirement number
2. Maximize employer match
3. Automate contributions
4. Increase contributions annually
5. Review and rebalance yearly
""",
            readTime: 6,
            icon: "building.columns.fill",
            color: "5AC8FA"
        )
    ]
}
