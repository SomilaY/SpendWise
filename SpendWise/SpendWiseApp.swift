import SwiftUI
import SwiftData

@main
struct SpendWiseApp: App {
    var body: some Scene {
        WindowGroup {
            ExpenseListView()
        }
        // This line sets up the database for the whole app.
        // Without it, any view using @Query will fail, so it's the
        // first thing to check if your data ever "disappears".
        .modelContainer(for: Expense.self)
    }
}
