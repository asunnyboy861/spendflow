import Foundation
import SwiftUI

enum SyncStatus: Equatable {
    case notConfigured
    case disabled
    case syncing
    case synced(Date)
    case failed(SyncError)
    case conflict

    var displayText: String {
        switch self {
        case .notConfigured:
            return "Not Configured"
        case .disabled:
            return "Disabled"
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            let formatter = RelativeDateTimeFormatter()
            return "Synced \(formatter.localizedString(for: date, relativeTo: Date()))"
        case .failed(let error):
            return "Failed: \(error.localizedDescription)"
        case .conflict:
            return "Conflict Detected"
        }
    }

    var icon: String {
        switch self {
        case .notConfigured, .disabled:
            return "icloud.slash"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .synced:
            return "checkmark.icloud"
        case .failed, .conflict:
            return "exclamationmark.icloud"
        }
    }

    var color: Color {
        switch self {
        case .notConfigured, .disabled:
            return .secondary
        case .syncing:
            return .accentColor
        case .synced:
            return .green
        case .failed, .conflict:
            return .red
        }
    }
}
