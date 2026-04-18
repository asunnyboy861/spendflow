import SwiftUI

struct BillReminderView: View {
    @StateObject private var viewModel: BillReminderViewModel
    @State private var showAddBill = false
    
    init(
        repository: BillReminderRepository = BillReminderRepository(),
        reminderService: BillReminderService = BillReminderService()
    ) {
        _viewModel = StateObject(wrappedValue: BillReminderViewModel(
            repository: repository,
            reminderService: reminderService
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.l) {
                summaryCard
                
                if !viewModel.overdueBills.isEmpty {
                    overdueSection
                }
                
                if !viewModel.upcomingBills.isEmpty {
                    upcomingSection
                }
                
                allBillsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Bills")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddBill = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddBill) {
            AddBillView(viewModel: viewModel)
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    private var summaryCard: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            HStack(spacing: DesignTokens.Spacing.l) {
                VStack(spacing: 4) {
                    Text("\(viewModel.overdueBills.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.expenseRed)
                    Text("Overdue")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("\(viewModel.upcomingBills.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.warningOrange)
                    Text("Upcoming")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text(viewModel.totalUpcoming.currencyFormatted)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Due Soon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private var overdueSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.expenseRed)
                Text("Overdue")
                    .font(.headline)
                    .foregroundStyle(.expenseRed)
            }
            
            ForEach(viewModel.overdueBills) { bill in
                BillRow(bill: bill) {
                    viewModel.markAsPaid(bill)
                }
            }
        }
    }
    
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.warningOrange)
                Text("Due Soon")
                    .font(.headline)
            }
            
            ForEach(viewModel.upcomingBills) { bill in
                BillRow(bill: bill) {
                    viewModel.markAsPaid(bill)
                }
            }
        }
    }
    
    private var allBillsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
            Text("All Bills")
                .font(.headline)
            
            if viewModel.bills.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.clock",
                    title: "No Bills Yet",
                    subtitle: "Add your recurring bills to get reminders before they're due"
                )
            } else {
                ForEach(viewModel.bills) { bill in
                    BillRow(bill: bill) {
                        viewModel.markAsPaid(bill)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteBill(bill.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BillReminderView()
    }
}
