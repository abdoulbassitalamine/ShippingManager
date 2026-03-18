import SwiftUI

struct ShippingStatsView: View {

    let plan: ShippingPlan

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundStyle(Color.accentBlue)
                Text("Récapitulatif")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .tracking(0.8)
                Spacer()
                Text(plan.generatedAt.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textTertiary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                      spacing: DS.Spacing.sm) {
                StatTileView(icon: "shippingbox.fill",
                             label: "Conteneurs expédiés",
                             value: "\(plan.shippedContainers.count)",
                             color: .statusSuccess)

                StatTileView(icon: "clock.badge.xmark",
                             label: "Conteneurs reportés",
                             value: "\(plan.deferredContainers.count)",
                             color: plan.deferredContainers.isEmpty ? .statusNeutral : .statusWarning)

                StatTileView(icon: "eurosign.circle.fill",
                             label: "Recettes totales",
                             value: plan.totalRevenue.euroFormatted,
                             color: .statusSuccess)

                StatTileView(icon: "chart.line.uptrend.xyaxis",
                             label: "Taux moyen",
                             value: plan.averageFillRate.percentFormatted,
                             color: fillRateColor(plan.averageFillRate))
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Commandes chargées")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                    Text("\(plan.totalShippedOrders) / \(plan.totalOrders + plan.deferredOrders.count)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.textPrimary)
                }
                Spacer()
                Text("Algorithme : \(plan.algorithmName)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(DS.Spacing.md)
        .background(
            LinearGradient(colors: [Color.surfacePrimary, Color.surfaceSecondary],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .strokeBorder(Color.accentBlue.opacity(0.3), lineWidth: 1)
        )
        .cardShadow()
    }

    private func fillRateColor(_ rate: Double) -> Color {
        if rate >= 0.8 { return .statusSuccess }
        if rate >= 0.5 { return .statusWarning }
        return .statusDanger
    }
}

struct StatTileView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.md)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md)
            .strokeBorder(color.opacity(0.25), lineWidth: 1))
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }
}
