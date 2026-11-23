import SwiftUI

// Lets us write colours as hex codes, like in web design: Color(hex: 0x00C896)
extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,   // pull out the red part
            green: Double((hex >> 8) & 0xFF) / 255,    // the green part
            blue:  Double(hex & 0xFF) / 255,           // the blue part
            opacity: opacity
        )
    }
}

// One place for every colour and size in the app. Like a paint swatch card:
// if you decide emerald should be slightly different, you change it here
// once and the whole app updates.
enum Theme {
    static let emerald = Color(hex: 0x00C896)   // growth, savings, healthy
    static let navy    = Color(hex: 0x0A1020)   // main background
    static let teal    = Color(hex: 0x4FD1C5)   // soft highlights
    static let silver  = Color(hex: 0xC6CCD8)   // labels and secondary text
    static let amber   = Color(hex: 0xF5B84B)   // gentle warning (instead of harsh red)

    static let cornerRadius: CGFloat = 24
}
