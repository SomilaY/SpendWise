import SwiftUI

struct InsightCardView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Theme.teal)

            VStack(alignment: .leading, spacing: 4) {
                Text("INSIGHT")
                    .font(.caption2)
                    .fontWeight(.light)
                    .tracking(2)
                    .foregroundStyle(Theme.silver)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}
