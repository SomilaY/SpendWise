import Foundation
import SwiftData

// A fixed list of categories. Using an enum (a "multiple choice" type)
// means we can never accidentally type "Fod" instead of "Food".
// Codable lets SwiftData save it to disk.
// CaseIterable lets us loop over every category later (e.g. for a picker).
enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case entertainment = "Entertainment"
    case other = "Other"

    // Identifiable lets SwiftUI tell the categories apart in lists and charts.
    var id: String { rawValue }

    // An SF Symbol (Apple's built-in icon set) for each category.
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .bills: return "doc.text.fill"
        case .entertainment: return "film.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// @Model tells SwiftData: "save this type to the database".
// Think of this as one row in a spreadsheet, where each property is a column.
@Model
final class Expense {
    var title: String          // e.g. "Lunch at Nando's"
    var amount: Double         // e.g. 120.50
    var category: ExpenseCategory
    var date: Date

    // The initializer is how we create a new expense in code.
    // The default date is "right now" so we don't always have to pass one.
    init(title: String, amount: Double, category: ExpenseCategory, date: Date = .now) {
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
    }
}
