import SwiftUI

// A reusable "entrance" recipe, like .glassCard(). Add .floatIn(order: 2)
// to any view and it springs up into place when the screen first appears.
struct FloatIn: ViewModifier {
    // Position in the sequence: 0 goes first, 1 second, and so on.
    let order: Int

    // False = hidden and lowered. True = in its final spot.
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            // 40 points lower than its final spot until it appears.
            .offset(y: appeared ? 0 : 40)
            // Slight shrink, so it "grows" into place as it floats up.
            .scaleEffect(appeared ? 1 : 0.96)
            .onAppear {
                // A spring overshoots slightly and settles, like a ball
                // landing on a trampoline instead of a stone dropping.
                // The delay is what staggers the cards one after another.
                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.78)
                    .delay(Double(order) * 0.08)
                ) {
                    appeared = true
                }
            }
    }
}

extension View {
    func floatIn(order: Int) -> some View {
        modifier(FloatIn(order: order))
    }
}
