import SwiftUI

struct SummaryHeaderView: View {
    // Listens to the phone's tilt. @StateObject keeps one broadcaster
    // alive for as long as this card exists.
    @StateObject private var motion = MotionManager()

    let total: Double    // spent this month
    let budget: Double   // monthly limit

    // Shared with the main screen, so the arrows can change the month.
    @Binding var month: Date

    // How much of the budget is used (0.5 = half). Guard against dividing by zero.
    private var progress: Double { budget > 0 ? total / budget : 0 }
    private var remaining: Double { budget - total }
    private var isOver: Bool { remaining < 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MonthPickerView(selectedMonth: $month)

            // Big bold figure. numericText makes digits roll like an odometer
            // when the value changes.
            Text(total.asCurrency)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.snappy, value: total)

            // The progress bar: a faint track with a glowing fill on top.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.10))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isOver ? [Theme.amber, Theme.amber]
                                               : [Theme.emerald, Theme.teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        // min(...) stops the bar overflowing past 100%.
                        .frame(width: geo.size.width * min(progress, 1))
                        .shadow(color: (isOver ? Theme.amber : Theme.emerald).opacity(0.6), radius: 8)
                }
            }
            .frame(height: 8)
            .animation(.spring(duration: 0.8), value: progress)

            Text(isOver
                 ? "\((-remaining).asCurrency) over budget"
                 : "\(remaining.asCurrency) left of \(budget.asCurrency)")
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundStyle(Theme.silver)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: 24)
        // 3D tilt: rotate the card around the X and Y axes.
        // The numbers control sensitivity. Raise them for a stronger effect.
        .rotation3DEffect(.radians(motion.pitch * 0.25), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(.radians(motion.roll * 0.25), axis: (x: 0, y: 1, z: 0))
        // Parallax: the whole card also slides slightly the opposite way,
        // so it feels like it's floating above the background.
        .offset(x: motion.roll * 8, y: motion.pitch * 8)
        // Start and stop the sensors with the screen's life.
        .onAppear { motion.start() }
        .onDisappear { motion.stop() }
    }
}

#Preview {
    ZStack {
        AmbientBackground(budgetUsed: 0.5)
        SummaryHeaderView(total: 4200, budget: 10000, month: .constant(.now)).padding()
    }
}
