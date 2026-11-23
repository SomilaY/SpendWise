import SwiftUI
import SwiftData
import UIKit

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @AppStorage("monthlyBudget") private var monthlyBudget = 10_000.0

    // Which "drawer" of the filing cabinet we're looking at. Starts at now.
    @State private var selectedMonth = Date()

    // Three possible sheets:
    @State private var showingAddExpense = false
    @State private var expenseToEdit: Expense?    // set this to open the edit form
    @State private var showingSettings = false

    // Everything below uses the SELECTED month, not just the current one.
    private var monthExpenses: [Expense] { ExpenseSummary.inMonth(expenses, of: selectedMonth) }
    private var monthTotal: Double { ExpenseSummary.total(of: monthExpenses) }
    private var budgetUsed: Double { monthlyBudget > 0 ? monthTotal / monthlyBudget : 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground(budgetUsed: budgetUsed)

                if expenses.isEmpty {
                    ContentUnavailableView(
                        "No Expenses Yet",
                        systemImage: "creditcard",
                        description: Text("Tap + to add your first expense.")
                    )
                } else {
                    List {
                        // Title on the left, settings button on the right.
                        HStack {
                            Text("SpendWise")
                                .font(.system(size: 34, weight: .thin))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                showingSettings = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundStyle(Theme.silver)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .buttonStyle(.plain)   // keeps the tap inside the button only
                        }
                        .floatIn(order: 0)
                        .clearListRow()

                        SummaryHeaderView(total: monthTotal, budget: monthlyBudget, month: $selectedMonth)
                            .floatIn(order: 1)
                            .clearListRow()

                        if let insight = ExpenseSummary.insight(for: monthExpenses, total: monthTotal) {
                            InsightCardView(message: insight)
                                .floatIn(order: 2)
                                .clearListRow()
                        }

                        if !monthExpenses.isEmpty {
                            SpendingChartView(totals: ExpenseSummary.totalsByCategory(monthExpenses))
                                .floatIn(order: 3)
                                .clearListRow()
                        }

                        Text("TRANSACTIONS")
                            .font(.caption)
                            .fontWeight(.light)
                            .tracking(2)
                            .foregroundStyle(Theme.silver)
                            .clearListRow()

                        // A friendly message if this month's drawer is empty.
                        if monthExpenses.isEmpty {
                            Text("Nothing spent in this month.")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundStyle(Theme.silver)
                                .clearListRow()
                        }

                        ForEach(monthExpenses) { expense in
                            // Wrapping the row in a Button makes it tappable.
                            // Tapping sets expenseToEdit, which opens the edit sheet.
                            Button {
                                expenseToEdit = expense
                            } label: {
                                ExpenseRow(expense: expense)
                            }
                            .buttonStyle(.plain)
                            .clearListRow()
                        }
                        .onDelete(perform: deleteExpenses)

                        Color.clear.frame(height: 70).clearListRow()
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.navy)
                        .frame(width: 62, height: 62)
                        .background(
                            LinearGradient(colors: [Theme.emerald, Theme.teal],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            in: Circle()
                        )
                        .shadow(color: Theme.emerald.opacity(0.6), radius: 18, y: 6)
                }
                .padding(24)
            }
            .toolbar(.hidden, for: .navigationBar)
            // Sheet 1: add a new expense (blank form).
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            // Sheet 2: edit an expense. It opens whenever expenseToEdit is set,
            // and passes that expense in so the form is pre-filled.
            .sheet(item: $expenseToEdit) { expense in
                AddExpenseView(expense: expense)
            }
            // Sheet 3: budget settings.
            .sheet(isPresented: $showingSettings) {
                BudgetSettingsView()
            }
        }
        .preferredColorScheme(.dark)
    }

    // The list on screen shows monthExpenses, so "row 2" means the second
    // item of THAT list. We must look it up there, not in the full list,
    // otherwise we'd delete the wrong expense.
    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(monthExpenses[index])
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 14) {
            // Icon inside a softly glowing glass circle.
            Image(systemName: expense.category.icon)
                .foregroundStyle(Theme.teal)
                .frame(width: 42, height: 42)
                .background(Theme.teal.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(expense.category.rawValue) · \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundStyle(Theme.silver)
            }

            Spacer()

            Text(expense.amount.asCurrency)
                .font(.headline)
                .foregroundStyle(.white)
        }
        // Smaller padding than the big cards, so rows feel lighter.
        .glassCard(padding: 14)
    }
}

#Preview {
    ExpenseListView()
        .modelContainer(for: Expense.self, inMemory: true)
}
