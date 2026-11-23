import SwiftUI

struct AmbientBackground: View {
    // 0 = no budget used, 1 = fully used. Drives the glow colour.
    var budgetUsed: Double

    // Emerald while healthy, amber as you near your limit (same as before).
    private var glow: Color {
        budgetUsed < 0.75 ? Theme.emerald : Theme.amber
    }

    var body: some View {
        // TimelineView re-draws its content many times a second.
        // `t` is the number of seconds that have passed, which we use as
        // a clock to make the points drift, like a slow pendulum.
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            // sin() swings smoothly between -1 and 1 forever.
            // Multiplying shrinks it to a gentle wobble, and the different
            // speeds (0.3, 0.4, ...) stop the points moving in lockstep.
            let wobbleA = Float(sin(t * 0.30)) * 0.08
            let wobbleB = Float(cos(t * 0.40)) * 0.08
            let wobbleC = Float(sin(t * 0.25 + 1)) * 0.08

            MeshGradient(
                width: 3,
                height: 3,
                // A 3x3 grid of points. (0,0) is top-left, (1,1) is bottom-right.
                // The corners and edges stay pinned so the gradient always
                // fills the screen. Only the centre points drift.
                points: [
                    [0.0, 0.0],               [0.5, 0.0],                      [1.0, 0.0],
                    [0.0, 0.5],               [0.5 + wobbleA, 0.5 + wobbleB],  [1.0, 0.5],
                    [0.0, 1.0],               [0.5 + wobbleC, 1.0],            [1.0, 1.0]
                ],
                // One colour per point, in the same order as the grid above.
                // Mostly deep navy, with pockets of glowing colour.
                colors: [
                    Theme.navy,               Theme.navy,                      Theme.teal.opacity(0.35),
                    glow.opacity(0.55),       Theme.navy,                      Theme.navy,
                    Theme.navy,               Theme.emerald.opacity(0.30),     Theme.navy
                ]
            )
        }
        .ignoresSafeArea()
        // When the budget status changes, the glow colour fades smoothly,
        // like a dimmer switch.
        .animation(.easeInOut(duration: 1.2), value: glow)
    }
}
