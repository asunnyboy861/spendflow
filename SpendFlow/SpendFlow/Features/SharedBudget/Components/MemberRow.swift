import SwiftUI

struct MemberAvatar: View {
    let member: SharedMember
    let size: CGFloat
    
    init(member: SharedMember, size: CGFloat = 40) {
        self.member = member
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: member.avatarColor))
                .frame(width: size, height: size)
            
            Text(member.initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

struct MemberRow: View {
    let member: SharedMember
    let isCurrentUser: Bool
    let onRemove: (() -> Void)?
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            MemberAvatar(member: member)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(member.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(member.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: member.role.icon)
                    .font(.caption)
                Text(member.role.rawValue)
                    .font(.caption)
            }
            .foregroundStyle(member.role == .owner ? .warningOrange : .secondary)
            
            if let onRemove = onRemove, member.role != .owner {
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }
}

#Preview {
    VStack(spacing: 8) {
        MemberRow(
            member: SharedMember(name: "John Doe", email: "john@email.com", role: .owner),
            isCurrentUser: true,
            onRemove: nil
        )
        MemberRow(
            member: SharedMember(name: "Jane Doe", email: "jane@email.com", role: .member, avatarColor: "FF6B6B"),
            isCurrentUser: false,
            onRemove: {}
        )
    }
    .padding()
}
