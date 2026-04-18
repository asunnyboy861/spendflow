import Foundation
import SwiftUI

enum BankSyncStatus: Equatable {
    case notConnected
    case connecting
    case connected(Date)
    case syncing
    case synced(Date)
    case failed(BankSyncError)
    
    var displayText: String {
        switch self {
        case .notConnected:
            return "Not Connected"
        case .connecting:
            return "Connecting..."
        case .connected(let date):
            let formatter = RelativeDateTimeFormatter()
            return "Connected \(formatter.localizedString(for: date, relativeTo: Date()))"
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            let formatter = RelativeDateTimeFormatter()
            return "Synced \(formatter.localizedString(for: date, relativeTo: Date()))"
        case .failed(let error):
            return "Failed: \(error.localizedDescription)"
        }
    }
    
    var icon: String {
        switch self {
        case .notConnected:
            return "link.badge.plus"
        case .connecting, .syncing:
            return "arrow.triangle.2.circlepath"
        case .connected, .synced:
            return "checkmark.link"
        case .failed:
            return "exclamationmark.link"
        }
    }
    
    var color: Color {
        switch self {
        case .notConnected:
            return .secondary
        case .connecting, .syncing:
            return .accentBlue
        case .connected, .synced:
            return .incomeGreen
        case .failed:
            return .expenseRed
        }
    }
}

enum BankSyncError: Error, LocalizedError, Equatable {
    case connectionFailed(String)
    case authenticationFailed
    case networkError
    case invalidToken
    case rateLimitExceeded
    case accountNotFound
    case syncFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidToken:
            return "Session expired. Please reconnect your account."
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .accountNotFound:
            return "Account not found. It may have been closed."
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        }
    }
}
