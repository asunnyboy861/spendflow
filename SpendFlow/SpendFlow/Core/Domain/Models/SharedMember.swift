import Foundation

struct SharedMember: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var role: SharingRole
    var avatarColor: String
    var joinedDate: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        role: SharingRole = .member,
        avatarColor: String = "007AFF",
        joinedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarColor = avatarColor
        self.joinedDate = joinedDate
    }
    
    var initials: String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .prefix(2)
            .joined()
            .uppercased()
    }
}

enum SharingRole: String, Codable, CaseIterable {
    case owner = "Owner"
    case member = "Member"
    case viewer = "Viewer"
    
    var canEdit: Bool {
        self == .owner || self == .member
    }
    
    var canShare: Bool {
        self == .owner
    }
    
    var icon: String {
        switch self {
        case .owner: return "crown.fill"
        case .member: return "person.fill"
        case .viewer: return "eye.fill"
        }
    }
}

struct SharedTransaction: Identifiable, Codable {
    let id: UUID
    let transactionId: UUID
    let addedBy: SharedMember
    let addedDate: Date
    var notes: String
}

struct SharingInvitation: Identifiable, Codable {
    let id: UUID
    let code: String
    let invitedBy: SharedMember
    let createdDate: Date
    var isUsed: Bool
    
    init(
        id: UUID = UUID(),
        code: String = UUID().uuidString.prefix(8).uppercased(),
        invitedBy: SharedMember,
        createdDate: Date = Date(),
        isUsed: Bool = false
    ) {
        self.id = id
        self.code = code
        self.invitedBy = invitedBy
        self.createdDate = createdDate
        self.isUsed = isUsed
    }
}
