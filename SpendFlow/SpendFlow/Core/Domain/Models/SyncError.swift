import Foundation

enum SyncError: Error, Equatable {
    case notSignedIn
    case networkUnavailable
    case quotaExceeded
    case conflictDetected
    case unknown(String)

    var localizedDescription: String {
        switch self {
        case .notSignedIn:
            return "Please sign in to iCloud to enable sync"
        case .networkUnavailable:
            return "Network unavailable. Please check your connection"
        case .quotaExceeded:
            return "iCloud storage quota exceeded"
        case .conflictDetected:
            return "Sync conflict detected. Please resolve manually"
        case .unknown(let message):
            return "Sync failed: \(message)"
        }
    }

    static func == (lhs: SyncError, rhs: SyncError) -> Bool {
        switch (lhs, rhs) {
        case (.notSignedIn, .notSignedIn),
             (.networkUnavailable, .networkUnavailable),
             (.quotaExceeded, .quotaExceeded),
             (.conflictDetected, .conflictDetected):
            return true
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}
