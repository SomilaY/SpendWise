import SwiftUI
import SwiftData
import UIKit

struct AddExpenseView: View {
    // modelContext is the "pen" we use to write into the database.
    @Environment(\.modelContext) private var modelContext
    // dismiss closes this screen, like pressing a back button from code.
    @Environment(\.dismiss) private var dismiss

    // @State = the form's scratchpad. These hold what the user has typed
    // so far. Nothing is saved until they press Save.
    @State private var title = ""
    @State private var amount: Double?   // Optional: empty until they type something
    @State private var category: ExpenseCategory = .food
    @State private var date = Date()

    // The Save button only works when the form makes sense.
    // A computed property is recalculated every time the screen refreshes.
    private var isValid: Bool {
        guard let amount else { return false }
        return !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0
    }

    // One shared "glass row" look for every section of the form.
    private var glassRow: some View {
        Rectangle().fill(.ultraThinMaterial)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground(budgetUsed: 0.3)

                Form {
                    Section("Details") {
                        TextField("What did you spend on?", text: $title)
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    .listRowBackground(glassRow)

                    Section("Category") {
                        Picker("Category", selection: $category) {
                            ForEach(ExpenseCategory.allCases) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                    }
                    .listRowBackground(glassRow)

                    Section("Date") {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                    .listRowBackground(glassRow)
                }
                // Hide the form's default grey background so the glow shows.
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.silver)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!isValid)
                }
            }
            // Emerald becomes the app's accent colour (buttons, pickers, etc.)
            .tint(Theme.emerald)
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        guard let amount else { return }

        let expense = Expense(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            category: category,
            date: date
        )
        modelContext.insert(expense)

        // The "success" buzz: two quick, soft taps. It's the same pattern
        // Apple Pay uses, so it feels familiar and trustworthy.
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: Expense.self, inMemory: true)
}
