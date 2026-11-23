import SwiftUI
import UIKit

// A compact "< NOVEMBER 2026 >" control that lives inside the hero card.
struct MonthPickerView: View {
    // @Binding is a shared remote control: when this view changes the month,
    // the main screen's month changes too, because they hold the same value.
    @Binding var selectedMonth: Date

    // True when we're already looking at the current month.
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: .now, toGranularity: .month)
    }

    var body: some View {
        HStack {
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(selectedMonth.formatted(.dateTime.month(.wide).year()).uppercased())
                .font(.caption)
                .fontWeight(.light)
                .tracking(2)
                // Digits and letters swap smoothly when the month changes.
                .contentTransition(.numericText())

            Spacer()

            Button { changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
            }
            // You can't browse into the future, so the arrow dims and stops
            // working once you reach the current month.
            .disabled(isCurrentMonth)
            .opacity(isCurrentMonth ? 0.3 : 1)
        }
        .foregroundStyle(Theme.silver)
        // IMPORTANT: .plain stops the whole List row from reacting when one
        // button is tapped. Without it, SwiftUI can fire BOTH arrows at once
        // when anything in the row is pressed.
        .buttonStyle(.plain)
    }

    private func changeMonth(by value: Int) {
        // Calendar does the maths: "one month before 1 March" is handled
        // correctly, even across year ends and leap years.
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) else { return }

        // A tiny "tick", like a dial clicking into place.
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.snappy) { selectedMonth = newDate }
    }
}
