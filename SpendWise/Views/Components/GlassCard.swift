import SwiftUI

// A ViewModifier is a reusable "style recipe". Add .glassCard() to ANY view
// and it gets wrapped in a frosted glass panel, like a stamp you can press
// onto anything.
struct GlassCard: ViewModifier {
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        // One shape, reused for every layer so the layers line up exactly.
        let shape = RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)

        content
            .padding(padding)
            // Layer 1: iOS's built-in frosted blur (shows the glow behind it).
            .background(.ultraThinMaterial, in: shape)
            // Layer 2: a faint white tint so the glass feels slightly milky.
            .background(Color.white.opacity(0.05), in: shape)
            // Layer 3: a thin glowing edge, brighter at the top-left where
            // light would hit it. This one detail sells the "glass" look.
            .overlay(
                shape.strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.04), Theme.teal.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            )
            // Layer 4: a soft shadow underneath so the card floats.
            .shadow(color: .black.opacity(0.35), radius: 24, y: 12)
    }
}

extension View {
    // The short version you'll actually type: .glassCard()
    func glassCard(padding: CGFloat = 20) -> some View {
        modifier(GlassCard(padding: padding))
    }

    // Lists normally draw their own grey rows. This removes that, so our
    // glass cards sit directly on the glowing background.
    func clearListRow() -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
    }
}
