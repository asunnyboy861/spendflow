import SwiftUI
import UniformTypeIdentifiers

struct ExportView: View {
    @StateObject private var viewModel: ExportViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ExportViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.l) {
                    ExportOptionsView(viewModel: viewModel)
                        .cardStyle()

                    exportButtonsSection

                    if let errorMessage = viewModel.errorMessage {
                        errorSection(message: errorMessage)
                    }

                    if viewModel.showSuccessMessage {
                        successSection
                    }

                    infoSection
                }
                .padding(.horizontal, DesignTokens.Spacing.m)
                .padding(.vertical, DesignTokens.Spacing.m)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let url = viewModel.exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private var exportButtonsSection: some View {
        VStack(spacing: DesignTokens.Spacing.m) {
            HapticButton("Export All Data", style: .primary) {
                viewModel.exportData()
            }
            .disabled(!viewModel.canExport || viewModel.isExporting)

            HapticButton("Export Transactions Only", style: .secondary) {
                viewModel.exportTransactionsOnly()
            }
            .disabled(viewModel.isExporting)

            if viewModel.isExporting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.top, DesignTokens.Spacing.s)
            }
        }
        .cardStyle()
    }

    private func errorSection(message: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.s) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)

            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium))
    }

    private var successSection: some View {
        HStack(spacing: DesignTokens.Spacing.s) {
            Image(systemName: "checkmark.circle")
                .foregroundColor(.green)

            Text("Export successful! Share your file.")
                .font(.subheadline)
                .foregroundColor(.green)

            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium))
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            Label {
                Text("Exported files can be opened in spreadsheet apps like Excel or Numbers.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "doc.text")
                    .foregroundColor(.accentColor)
            }

            Label {
                Text("Your data is exported locally. No data is sent to external servers.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "lock.shield")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.s)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
