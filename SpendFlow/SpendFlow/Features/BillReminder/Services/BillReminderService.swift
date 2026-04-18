import Foundation
import UserNotifications

class BillReminderService {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    func scheduleReminder(for bill: BillReminder) {
        guard bill.reminderDaysBefore > 0 else { return }
        
        let reminderDate = Calendar.current.date(byAdding: .day, value: -bill.reminderDaysBefore, to: bill.dueDate)
        
        guard let reminderDate = reminderDate, reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Bill Reminder"
        content.body = "\(bill.name) - \(bill.amount.currencyFormatted) is due in \(bill.reminderDaysBefore) days"
        content.sound = .default
        content.categoryIdentifier = "BILL_REMINDER"
        content.userInfo = ["billId": bill.id.uuidString]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "bill-\(bill.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    func scheduleDueDateReminder(for bill: BillReminder) {
        guard bill.dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Bill Due Today"
        content.body = "\(bill.name) - \(bill.amount.currencyFormatted) is due today"
        content.sound = .default
        content.categoryIdentifier = "BILL_DUE"
        content.userInfo = ["billId": bill.id.uuidString]
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: bill.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "bill-due-\(bill.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    func cancelReminder(for billId: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            "bill-\(billId.uuidString)",
            "bill-due-\(billId.uuidString)"
        ])
    }
    
    func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
