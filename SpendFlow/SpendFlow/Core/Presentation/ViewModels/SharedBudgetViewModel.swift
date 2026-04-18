import Combine
import Foundation

class SharedBudgetViewModel: ObservableObject {
    @Published var members: [SharedMember] = []
    @Published var currentMember: SharedMember?
    @Published var invitations: [SharingInvitation] = []
    @Published var isLoading: Bool = false
    
    private let sharingService: SharingService
    
    init(sharingService: SharingService) {
        self.sharingService = sharingService
        loadData()
    }
    
    func loadData() {
        members = sharingService.fetchMembers()
        currentMember = sharingService.getCurrentMember()
        invitations = sharingService.fetchInvitations()
    }
    
    func setupAsOwner(name: String, email: String) {
        let owner = SharedMember(
            name: name,
            email: email,
            role: .owner,
            avatarColor: "007AFF"
        )
        sharingService.setCurrentMember(owner)
        sharingService.addMember(owner)
        loadData()
    }
    
    func createInvitation() -> SharingInvitation? {
        guard let current = currentMember else { return nil }
        let invitation = sharingService.createInvitation(invitedBy: current)
        loadData()
        return invitation
    }
    
    func joinWithCode(_ code: String, name: String, email: String) -> Bool {
        let member = SharedMember(
            name: name,
            email: email,
            role: .member,
            avatarColor: randomColor()
        )
        let success = sharingService.joinWithCode(code, as: member)
        if success {
            loadData()
        }
        return success
    }
    
    func removeMember(_ memberId: UUID) {
        sharingService.removeMember(memberId)
        loadData()
    }
    
    var isOwner: Bool {
        currentMember?.role == .owner
    }
    
    var memberCount: Int {
        members.count
    }
    
    private func randomColor() -> String {
        let colors = ["FF6B6B", "4ECDC4", "45B7D1", "96CEB4", "FFEAA7", "DDA0DD", "FF9FF3", "54A0FF"]
        return colors.randomElement() ?? "007AFF"
    }
}
