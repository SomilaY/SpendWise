import Foundation

// One bar in the chart: "Food: R850".
// Identifiable lets Swift Charts tell the bars apart.
struct CategoryTotal: Identifiable {
    let category: ExpenseCategory
    let total: Double
    var id: ExpenseCategory { category }
}

// A tiny "calculator" with no screen of its own. It takes a pile of
// expenses and answers questions about them. Because it doesn't touch the UI
// or the database, it's also very easy to unit test later.
enum ExpenseSummary {

    // Keeps only the expenses from the current month.
    // Calendar handles the awkward parts for us (month lengths, leap years).
    static func thisMonth(_ expenses: [Expense]) -> [Expense] {
        expenses.filter {
            Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month)
        }
    }

    // Adds up every amount. reduce starts at 0 and adds each amount in turn,
    // like a till operator running a total.
    static func total(of expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    // Groups expenses by category, adds up each group, and sorts biggest first.
    // Think of sorting receipts into labelled envelopes, then weighing each one.
    static func totalsByCategory(_ expenses: [Expense]) -> [CategoryTotal] {
        // Dictionary(grouping:) makes the envelopes: [category: [expenses]]
        let grouped = Dictionary(grouping: expenses, by: { $0.category })

        return grouped
            .map { category, items in
                CategoryTotal(category: category, total: total(of: items))
            }
            .sorted { $0.total > $1.total }
    }

    // Looks at the numbers and writes one sentence about them.
    // This is simple rule-based logic: no real AI involved yet.
    static func insight(for expenses: [Expense], total: Double) -> String? {
        // totalsByCategory is sorted biggest-first, so .first is the top spender.
        guard let top = totalsByCategory(expenses).first, total > 0 else { return nil }
        let share = Int((top.total / total * 100).rounded())
        return "\(top.category.rawValue) is your biggest category this month, at \(share)% of your spending."
    }
}
