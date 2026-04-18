import Foundation
import Combine

class SharingService {
    
    private let defaults = UserDefaults.standard
    private let membersKey = "shared_members"
    private let invitationsKey = "sharing_invitations"
    private let currentMemberKey = "current_member"
    
    func getCurrentMember() -> SharedMember? {
        guard let data = defaults.data(forKey: currentMemberKey) else { return nil }
        return try? JSONDecoder().decode(SharedMember.self, from: data)
    }
    
    func setCurrentMember(_ member: SharedMember) {
        if let data = try? JSONEncoder().encode(member) {
            defaults.set(data, forKey: currentMemberKey)
        }
    }
    
    func fetchMembers() -> [SharedMember] {
        guard let data = defaults.data(forKey: membersKey) else { return [] }
        return (try? JSONDecoder().decode([SharedMember].self, from: data)) ?? []
    }
    
    func addMember(_ member: SharedMember) {
        var members = fetchMembers()
        if !members.contains(where: { $0.id == member.id }) {
            members.append(member)
            saveMembers(members)
        }
    }
    
    func removeMember(_ memberId: UUID) {
        var members = fetchMembers()
        members.removeAll { $0.id == memberId }
        saveMembers(members)
    }
    
    func createInvitation(invitedBy: SharedMember) -> SharingInvitation {
        let invitation = SharingInvitation(invitedBy: invitedBy)
        var invitations = fetchInvitations()
        invitations.append(invitation)
        saveInvitations(invitations)
        return invitation
    }
    
    func fetchInvitations() -> [SharingInvitation] {
        guard let data = defaults.data(forKey: invitationsKey) else { return [] }
        return (try? JSONDecoder().decode([SharingInvitation].self, from: data)) ?? []
    }
    
    func joinWithCode(_ code: String, as member: SharedMember) -> Bool {
        var invitations = fetchInvitations()
        guard let index = invitations.firstIndex(where: { $0.code == code && !$0.isUsed }) else {
            return false
        }
        invitations[index].isUsed = true
        saveInvitations(invitations)
        addMember(member)
        setCurrentMember(member)
        return true
    }
    
    private func saveMembers(_ members: [SharedMember]) {
        if let data = try? JSONEncoder().encode(members) {
            defaults.set(data, forKey: membersKey)
        }
    }
    
    private func saveInvitations(_ invitations: [SharingInvitation]) {
        if let data = try? JSONEncoder().encode(invitations) {
            defaults.set(data, forKey: invitationsKey)
        }
    }
}
