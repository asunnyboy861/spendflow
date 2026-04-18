import Combine
import Foundation

class BillReminderViewModel: ObservableObject {
    @Published var bills: [BillReminder] = []
    @Published var upcomingBills: [BillReminder] = []
    @Published var overdueBills: [BillReminder] = []
    @Published var isLoading: Bool = false
    
    private let repository: BillReminderRepository
    private let reminderService: BillReminderService
    
    init(
        repository: BillReminderRepository,
        reminderService: BillReminderService
    ) {
        self.repository = repository
        self.reminderService = reminderService
        loadData()
    }
    
    func loadData() {
        bills = repository.fetchAll().sorted { $0.dueDate < $1.dueDate }
        upcomingBills = repository.fetchUpcoming()
        overdueBills = repository.fetchOverdue()
    }
    
    func addBill(_ bill: BillReminder) {
        repository.add(bill)
        reminderService.scheduleReminder(for: bill)
        reminderService.scheduleDueDateReminder(for: bill)
        loadData()
    }
    
    func updateBill(_ bill: BillReminder) {
        repository.update(bill)
        reminderService.cancelReminder(for: bill.id)
        reminderService.scheduleReminder(for: bill)
        reminderService.scheduleDueDateReminder(for: bill)
        loadData()
    }
    
    func deleteBill(_ billId: UUID) {
        reminderService.cancelReminder(for: billId)
        repository.delete(billId)
        loadData()
    }
    
    func markAsPaid(_ bill: BillReminder) {
        var updatedBill = bill
        updatedBill.isPaid = true
        repository.update(updatedBill)
        reminderService.cancelReminder(for: bill.id)
        
        if bill.isRecurring, let nextDate = bill.nextDueDate {
            let newBill = BillReminder(
                name: bill.name,
                amount: bill.amount,
                dueDate: nextDate,
                category: bill.category,
                isRecurring: bill.isRecurring,
                recurrence: bill.recurrence,
                reminderDaysBefore: bill.reminderDaysBefore,
                notes: bill.notes
            )
            repository.add(newBill)
            reminderService.scheduleReminder(for: newBill)
            reminderService.scheduleDueDateReminder(for: newBill)
        }
        
        loadData()
    }
    
    var totalUpcoming: Double {
        upcomingBills.map { $0.amount }.reduce(0, +)
    }
    
    var totalOverdue: Double {
        overdueBills.map { $0.amount }.reduce(0, +)
    }
}
