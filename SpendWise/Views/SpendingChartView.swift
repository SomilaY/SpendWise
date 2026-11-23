import SwiftUI
import Charts

struct SpendingChartView: View {
    let totals: [CategoryTotal]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BY CATEGORY")
                .font(.caption2)
                .fontWeight(.light)
                .tracking(2)
                .foregroundStyle(Theme.silver)

            Chart(totals) { item in
                BarMark(
                    x: .value("Spent", item.total),
                    y: .value("Category", item.category.rawValue)
                )
                // Emerald fading into teal: the "growth" gradient.
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.emerald, Theme.teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
                .annotation(position: .trailing) {
                    Text(item.total.asCurrency)
                        .font(.caption)
                        .foregroundStyle(Theme.silver)
                }
            }
            .chartXAxis(.hidden)
            // Category names in silver, with no axis line cluttering the view.
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisValueLabel()
                        .foregroundStyle(Theme.silver)
                }
            }
            .frame(height: CGFloat(totals.count) * 44 + 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}
