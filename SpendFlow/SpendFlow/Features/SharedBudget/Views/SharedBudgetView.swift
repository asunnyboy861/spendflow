import SwiftUI

struct SharedBudgetView: View {
    @StateObject private var viewModel: SharedBudgetViewModel
    @State private var showInviteSheet = false
    @State private var showJoinSheet = false
    @State private var ownerName = ""
    @State private var ownerEmail = ""
    
    init(sharingService: SharingService = SharingService()) {
        _viewModel = StateObject(wrappedValue: SharedBudgetViewModel(sharingService: sharingService))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.l) {
                if viewModel.currentMember == nil {
                    setupView
                } else {
                    membersCard
                    actionsCard
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Shared Budget")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showInviteSheet) {
            InviteSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showJoinSheet) {
            JoinSheet(viewModel: viewModel)
        }
    }
    
    private var setupView: some View {
        VStack(spacing: DesignTokens.Spacing.l) {
            VStack(spacing: DesignTokens.Spacing.m) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.accentBlue)
                
                Text("Share Your Budget")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Manage finances together with your partner or family")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: DesignTokens.Spacing.m) {
                TextField("Your Name", text: $ownerName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Your Email", text: $ownerEmail)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                HapticButton("Create Shared Budget", style: .primary) {
                    viewModel.setupAsOwner(name: ownerName, email: ownerEmail)
                }
                .disabled(ownerName.isEmpty || ownerEmail.isEmpty)
                .opacity(ownerName.isEmpty || ownerEmail.isEmpty ? 0.5 : 1.0)
                
                Divider()
                
                HapticButton("Join Existing Budget", style: .secondary) {
                    showJoinSheet = true
                }
            }
            .padding(DesignTokens.Spacing.l)
            .cardStyle()
        }
        .padding(DesignTokens.Spacing.xl)
    }
    
    private var membersCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            HStack {
                Text("Members")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.memberCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ForEach(viewModel.members) { member in
                MemberRow(
                    member: member,
                    isCurrentUser: member.id == viewModel.currentMember?.id,
                    onRemove: viewModel.isOwner ? { viewModel.removeMember(member.id) } : nil
                )
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
    
    private var actionsCard: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            if viewModel.isOwner {
                HapticButton("Invite Member", style: .primary) {
                    showInviteSheet = true
                }
            }
            
            HapticButton("Join Another Budget", style: .secondary) {
                showJoinSheet = true
            }
        }
        .padding(DesignTokens.Spacing.l)
        .cardStyle()
    }
}

struct InviteSheet: View {
    @ObservedObject var viewModel: SharedBudgetViewModel
    @State private var invitationCode: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignTokens.Spacing.l) {
                if let code = invitationCode {
                    VStack(spacing: DesignTokens.Spacing.m) {
                        Text("Invitation Code")
                            .font(.headline)
                        
                        Text(code)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundStyle(.accentBlue)
                            .padding()
                            .background(Color.accentBlue.opacity(0.1))
                            .cornerRadius(12)
                        
                        Text("Share this code with your partner to join your budget")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(DesignTokens.Spacing.xl)
                    .cardStyle()
                } else {
                    VStack(spacing: DesignTokens.Spacing.m) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.accentBlue)
                        
                        Text("Create an invitation code to share with your partner")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HapticButton("Generate Code", style: .primary) {
                            invitationCode = viewModel.createInvitation()?.code
                        }
                    }
                    .padding(DesignTokens.Spacing.xl)
                    .cardStyle()
                }
            }
            .padding()
            .navigationTitle("Invite Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct JoinSheet: View {
    @ObservedObject var viewModel: SharedBudgetViewModel
    @State private var code = ""
    @State private var name = ""
    @State private var email = ""
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Enter Invitation Code") {
                    TextField("Code", text: $code)
                        .font(.system(.body, design: .monospaced))
                        .textInputAutocapitalization(.characters)
                }
                
                Section("Your Info") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.expenseRed)
                    }
                }
                
                Section {
                    HapticButton("Join Budget") {
                        if viewModel.joinWithCode(code, name: name, email: email) {
                            dismiss()
                        } else {
                            errorMessage = "Invalid or expired invitation code"
                        }
                    }
                    .disabled(code.isEmpty || name.isEmpty || email.isEmpty)
                    .opacity(code.isEmpty || name.isEmpty || email.isEmpty ? 0.5 : 1.0)
                }
            }
            .navigationTitle("Join Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SharedBudgetView()
    }
}
