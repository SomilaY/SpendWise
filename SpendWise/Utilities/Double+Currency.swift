import Foundation

extension Double {
    // Turns 120.5 into "R120.50" (or "$120.50", depending on the phone's region).
    // It's like a label printer: the number goes in, a nicely formatted
    // price tag comes out, and we only write this logic once.
    var asCurrency: String {
        // Use the phone's own currency, falling back to Rand if it can't tell.
        let code = Locale.current.currency?.identifier ?? "ZAR"
        return self.formatted(.currency(code: code))
    }
}
