import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ContactSupportViewModel()

    private let feedbackSubjects = [
        ("bug", "Bug Report", "ladybug", Color.expenseRed),
        ("feature", "Feature Request", "lightbulb", Color.incomeGreen),
        ("question", "Question", "questionmark.circle", Color.accentBlue),
        ("feedback", "General Feedback", "message", Color.warningOrange),
        ("other", "Other", "ellipsis", Color.secondary)
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
                        Text("How can we help?")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: DesignTokens.Spacing.m) {
                            ForEach(feedbackSubjects, id: \.0) { subject in
                                SubjectButton(
                                    icon: subject.2,
                                    title: subject.1,
                                    color: subject.3,
                                    isSelected: viewModel.selectedSubject == subject.0
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.selectedSubject = subject.0
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, DesignTokens.Spacing.s)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section("Your Information") {
                    TextField("Name", text: $viewModel.name)
                        .textContentType(.name)
                        .autocorrectionDisabled()

                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section("Message") {
                    ZStack(alignment: .topLeading) {
                        if viewModel.message.isEmpty {
                            Text("Please describe your issue or suggestion in detail...")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }

                        TextEditor(text: $viewModel.message)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                    }
                }

                Section {
                    Button {
                        Task {
                            await viewModel.submitFeedback()
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit Feedback")
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your feedback! We'll get back to you soon.")
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {}
                Button("Retry") {
                    Task {
                        await viewModel.submitFeedback()
                    }
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

private struct SubjectButton: View {
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.s) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

@MainActor
class ContactSupportViewModel: ObservableObject {
    @Published var selectedSubject = "bug"
    @Published var name = ""
    @Published var email = ""
    @Published var message = ""
    @Published var isSubmitting = false
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""

    private let feedbackAPIURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }

    func submitFeedback() async {
        guard canSubmit else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        let subjectMap: [String: String] = [
            "bug": "Bug Report",
            "feature": "Feature Request",
            "question": "Question",
            "feedback": "General Feedback",
            "other": "Other"
        ]

        let feedbackData: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
            "subject": subjectMap[selectedSubject] ?? "General Feedback",
            "message": message.trimmingCharacters(in: .whitespacesAndNewlines),
            "app_name": "SpendFlow"
        ]

        guard let url = URL(string: feedbackAPIURL) else {
            errorMessage = "Invalid API URL"
            showErrorAlert = true
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: feedbackData)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                showErrorAlert = true
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                showSuccessAlert = true
            } else {
                errorMessage = "Server error (\(httpResponse.statusCode)). Please try again later."
                showErrorAlert = true
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription). Please check your connection and try again."
            showErrorAlert = true
        }
    }
}

#Preview {
    ContactSupportView()
}
