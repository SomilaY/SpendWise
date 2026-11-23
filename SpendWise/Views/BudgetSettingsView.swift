import SwiftUI
import UIKit

struct BudgetSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // The saved budget. This is the same "sticky note" the main screen reads,
    // so changing it here updates the main screen instantly.
    @AppStorage("monthlyBudget") private var monthlyBudget = 10_000.0

    // A scratchpad copy. We only write to the real budget when Save is pressed,
    // so cancelling really does cancel.
    @State private var draft: Double?

    // Only allow a sensible budget (more than zero).
    private var isValid: Bool { (draft ?? 0) > 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground(budgetUsed: 0.3)

                Form {
                    Section {
                        TextField("Monthly budget", value: $draft, format: .number)
                            .keyboardType(.decimalPad)
                    } header: {
                        Text("Monthly budget")
                    } footer: {
                        // Explains what the number does, so it never feels mysterious.
                        Text("Your progress bar and glow colour are measured against this amount.")
                    }
                    .listRowBackground(Rectangle().fill(.ultraThinMaterial))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.silver)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let draft { monthlyBudget = draft }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .tint(Theme.emerald)
            // Start the scratchpad with the current budget.
            .onAppear { draft = monthlyBudget }
        }
        .preferredColorScheme(.dark)
        // A half-height sheet, since there's only one setting.
        .presentationDetents([.medium])
    }
}

#Preview {
    BudgetSettingsView()
}
