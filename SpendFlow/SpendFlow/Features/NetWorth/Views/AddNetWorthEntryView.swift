import SwiftUI

struct AddNetWorthEntryView: View {
    @ObservedObject var viewModel: NetWorthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var assets: [AssetItem] = []
    @State private var liabilities: [LiabilityItem] = []
    @State private var newAssetName = ""
    @State private var newAssetCategory: AssetCategory = .checking
    @State private var newAssetAmount = ""
    @State private var newLiabilityName = ""
    @State private var newLiabilityCategory: LiabilityCategory = .creditCard
    @State private var newLiabilityAmount = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Assets") {
                    ForEach(assets) { asset in
                        AssetLiabilityRow(
                            name: asset.name,
                            amount: asset.amount,
                            icon: asset.category.icon,
                            color: asset.category.color,
                            isAsset: true
                        )
                    }
                    .onDelete { indexSet in
                        assets.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Name", text: $newAssetName)
                        TextField("Amount", text: $newAssetAmount)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                    }
                    
                    Picker("Category", selection: $newAssetCategory) {
                        ForEach(AssetCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    
                    Button("Add Asset") {
                        addAsset()
                    }
                    .disabled(newAssetName.isEmpty || newAssetAmount.isEmpty)
                }
                
                Section("Liabilities") {
                    ForEach(liabilities) { liability in
                        AssetLiabilityRow(
                            name: liability.name,
                            amount: liability.amount,
                            icon: liability.category.icon,
                            color: liability.category.color,
                            isAsset: false
                        )
                    }
                    .onDelete { indexSet in
                        liabilities.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Name", text: $newLiabilityName)
                        TextField("Amount", text: $newLiabilityAmount)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                    }
                    
                    Picker("Category", selection: $newLiabilityCategory) {
                        ForEach(LiabilityCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    
                    Button("Add Liability") {
                        addLiability()
                    }
                    .disabled(newLiabilityName.isEmpty || newLiabilityAmount.isEmpty)
                }
                
                Section {
                    VStack(spacing: DesignTokens.Spacing.s) {
                        HStack {
                            Text("Total Assets")
                            Spacer()
                            Text(totalAssets.currencyFormatted)
                                .foregroundStyle(.incomeGreen)
                        }
                        HStack {
                            Text("Total Liabilities")
                            Spacer()
                            Text(totalLiabilities.currencyFormatted)
                                .foregroundStyle(.expenseRed)
                        }
                        Divider()
                        HStack {
                            Text("Net Worth")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(netWorth.currencyFormatted)
                                .fontWeight(.bold)
                                .foregroundStyle(netWorth >= 0 ? .incomeGreen : .expenseRed)
                        }
                    }
                    .font(.subheadline)
                }
                
                Section {
                    HapticButton("Save Entry") {
                        saveEntry()
                    }
                    .disabled(assets.isEmpty && liabilities.isEmpty)
                    .opacity(assets.isEmpty && liabilities.isEmpty ? 0.5 : 1.0)
                }
            }
            .navigationTitle("Update Net Worth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                loadExistingData()
            }
        }
    }
    
    private var totalAssets: Double {
        assets.map { $0.amount }.reduce(0, +)
    }
    
    private var totalLiabilities: Double {
        liabilities.map { $0.amount }.reduce(0, +)
    }
    
    private var netWorth: Double {
        totalAssets - totalLiabilities
    }
    
    private func addAsset() {
        guard let amount = Double(newAssetAmount) else { return }
        assets.append(AssetItem(name: newAssetName, category: newAssetCategory, amount: amount))
        newAssetName = ""
        newAssetAmount = ""
    }
    
    private func addLiability() {
        guard let amount = Double(newLiabilityAmount) else { return }
        liabilities.append(LiabilityItem(name: newLiabilityName, category: newLiabilityCategory, amount: amount))
        newLiabilityName = ""
        newLiabilityAmount = ""
    }
    
    private func loadExistingData() {
        if let latest = viewModel.currentEntry {
            assets = latest.assets
            liabilities = latest.liabilities
        }
    }
    
    private func saveEntry() {
        let entry = NetWorthEntry(
            date: Date(),
            assets: assets,
            liabilities: liabilities
        )
        viewModel.saveEntry(entry)
        dismiss()
    }
}

#Preview {
    AddNetWorthEntryView(viewModel: NetWorthViewModel(repository: NetWorthRepository()))
}
