import SwiftUI
import SwiftData
import UIKit

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // nil = we're adding a NEW expense.
    // Not nil = we're editing this existing one.
    let expense: Expense?

    // The form's scratchpad (nothing is saved until Save is pressed).
    @State private var title: String
    @State private var amount: Double?
    @State private var category: ExpenseCategory
    @State private var date: Date

    // A custom initializer: this is where we "pre-fill the form".
    // `State(initialValue:)` sets the starting value of each scratchpad field.
    // If there's no expense (adding), we use blank defaults instead.
    init(expense: Expense? = nil) {
        self.expense = expense
        _title = State(initialValue: expense?.title ?? "")
        _amount = State(initialValue: expense?.amount)
        _category = State(initialValue: expense?.category ?? .food)
        _date = State(initialValue: expense?.date ?? Date())
    }

    private var isEditing: Bool { expense != nil }

    private var isValid: Bool {
        guard let amount else { return false }
        return !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0
    }

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
                .scrollContentBackground(.hidden)
            }
            // The title changes depending on the mode.
            .navigationTitle(isEditing ? "Edit Expense" : "New Expense")
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
            .tint(Theme.emerald)
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        guard let amount else { return }
        let cleanTitle = title.trimmingCharacters(in: .whitespaces)

        if let expense {
            // EDITING: just change the existing row's values.
            // SwiftData notices the changes and saves them automatically,
            // like Google Docs. There's no separate "save" step.
            expense.title = cleanTitle
            expense.amount = amount
            expense.category = category
            expense.date = date
        } else {
            // ADDING: create a brand new row and hand it to the database.
            let newExpense = Expense(title: cleanTitle, amount: amount, category: category, date: date)
            modelContext.insert(newExpense)
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: Expense.self, inMemory: true)
}
