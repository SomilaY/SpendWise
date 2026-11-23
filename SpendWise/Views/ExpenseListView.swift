import SwiftUI
import SwiftData
import UIKit

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    // @AppStorage saves a simple value on the phone, like a sticky note
    // that survives closing the app. 10,000 is a placeholder; we can add
    // a settings screen to change it later.
    @AppStorage("monthlyBudget") private var monthlyBudget = 10_000.0

    @State private var showingAddExpense = false

    // Our "kitchen calculator" from before, now feeding the new design.
    private var monthExpenses: [Expense] { ExpenseSummary.thisMonth(expenses) }
    private var monthTotal: Double { ExpenseSummary.total(of: monthExpenses) }
    private var budgetUsed: Double { monthlyBudget > 0 ? monthTotal / monthlyBudget : 0 }

    var body: some View {
        NavigationStack {
            // ZStack stacks things like layers of paper:
            // the glowing background at the back, the content in front.
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
                        // App title: thin and elegant.
                        Text("SpendWise")
                            .font(.system(size: 34, weight: .thin))
                            .foregroundStyle(.white)
                            .floatIn(order: 0)
                            .clearListRow()

                        SummaryHeaderView(total: monthTotal, budget: monthlyBudget)
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

                        ForEach(expenses) { expense in
                            ExpenseRow(expense: expense)
                                .clearListRow()
                        }
                        .onDelete(perform: deleteExpenses)

                        // Extra space at the bottom so the floating button
                        // never covers the last row.
                        Color.clear.frame(height: 70).clearListRow()
                    }
                    .listStyle(.plain)
                    // Hides the List's default background so our glow shows through.
                    .scrollContentBackground(.hidden)
                }
            }
            // A floating action button, hovering over everything in the corner.
            .overlay(alignment: .bottomTrailing) {
                Button {
                    // A light tap, like pressing a physical button.
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
                        // A glow under the button, as if it's emitting light.
                        .shadow(color: Theme.emerald.opacity(0.6), radius: 18, y: 6)
                }
                .padding(24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
        // Dark mode first: always dark, whatever the phone's setting.
        .preferredColorScheme(.dark)
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(expenses[index])
        }
    }
}

// A separate small view for one row. Splitting the UI into small pieces
// keeps each file easy to read, like having one recipe card per dish
// instead of one giant cookbook page.
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
