import Foundation

struct BillReminder: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var dueDate: Date
    var category: String
    var isRecurring: Bool
    var recurrence: BillRecurrence
    var isPaid: Bool
    var reminderDaysBefore: Int
    var notes: String
    
    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        dueDate: Date,
        category: String,
        isRecurring: Bool = true,
        recurrence: BillRecurrence = .monthly,
        isPaid: Bool = false,
        reminderDaysBefore: Int = 3,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.category = category
        self.isRecurring = isRecurring
        self.recurrence = recurrence
        self.isPaid = isPaid
        self.reminderDaysBefore = reminderDaysBefore
        self.notes = notes
    }
    
    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: dueDate)).day ?? 0
    }
    
    var isOverdue: Bool {
        !isPaid && daysUntilDue < 0
    }
    
    var isDueSoon: Bool {
        !isPaid && daysUntilDue >= 0 && daysUntilDue <= reminderDaysBefore
    }
    
    var status: BillStatus {
        if isPaid {
            return .paid
        } else if isOverdue {
            return .overdue
        } else if isDueSoon {
            return .dueSoon
        } else {
            return .upcoming
        }
    }
    
    var nextDueDate: Date? {
        guard isRecurring else { return nil }
        return recurrence.nextDate(from: dueDate)
    }
}

enum BillRecurrence: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"
    
    func nextDate(from date: Date) -> Date? {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date)
        case .annually:
            return calendar.date(byAdding: .year, value: 1, to: date)
        }
    }
}

enum BillStatus {
    case paid
    case overdue
    case dueSoon
    case upcoming
    
    var displayText: String {
        switch self {
        case .paid: return "Paid"
        case .overdue: return "Overdue"
        case .dueSoon: return "Due Soon"
        case .upcoming: return "Upcoming"
        }
    }
    
    var icon: String {
        switch self {
        case .paid: return "checkmark.circle.fill"
        case .overdue: return "exclamationmark.circle.fill"
        case .dueSoon: return "clock.fill"
        case .upcoming: return "calendar"
        }
    }
    
    var color: String {
        switch self {
        case .paid: return "27AE60"
        case .overdue: return "E74C3C"
        case .dueSoon: return "F39C12"
        case .upcoming: return "007AFF"
        }
    }
}
