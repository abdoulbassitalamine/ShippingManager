import SwiftUI

struct ContainerCardView: View {

    let container: Container
    @State private var isExpanded = false
    @State private var appeared = false

    private var isShipped: Bool { container.willBeShipped }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            headerRow

            FillRateBarView(label: "Volume",
                            rate: container.volumeFillRate,
                            threshold: container.config.minFillThreshold,
                            detail: "\(container.totalVolume.m3Formatted) / \(container.config.maxVolume.m3Formatted)")

            FillRateBarView(label: "Poids",
                            rate: container.weightFillRate,
                            threshold: container.config.minFillThreshold,
                            detail: "\(container.totalWeight.kgFormatted) / \(container.config.maxWeight.kgFormatted)")

            HStack {
                Label("Recettes", systemImage: "eurosign.circle")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(container.totalRevenue.euroFormatted)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.statusSuccess)
            }

            Divider().background(Color.surfaceBorder)

            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(spacing: DS.Spacing.xs) {
                    ForEach(container.loadedOrders) { order in
                        HStack {
                            Image(systemName: order.priority.icon)
                                .font(.system(size: 11))
                                .foregroundStyle(order.priority.color)
                                .frame(width: 16)

                            Text(order.orderNumber)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color.textPrimary)

                            Text(order.description)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)

                            Spacer()

                            Text(order.price.euroFormatted)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color.statusSuccess)
                        }
                        .padding(.vertical, 3)
                    }
                }
                .padding(.top, DS.Spacing.xs)
            } label: {
                Text("\(container.loadedOrders.count) commande(s) chargée(s)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.accentBlue)
            }
            .tint(Color.accentBlue)
        }
        .padding(DS.Spacing.md)
        .background(
            ZStack {
                Color.surfacePrimary
                if isShipped {
                    RadialGradient(
                        colors: [Color.accentBlue.opacity(0.08), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 200
                    )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .strokeBorder(
                    isShipped ? Color.accentBlue.opacity(0.5) : Color.surfaceBorder,
                    lineWidth: 1
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .cardShadow()
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Conteneur #\(container.number)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)

                if container.hasPriorityOrders {
                    Label("Prioritaires", systemImage: "flame.fill")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.priorityUrgent)
                }
            }
            Spacer()
            statusBadge
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isShipped ? Color.statusSuccess : Color.statusNeutral)
                .frame(width: 7, height: 7)
            Text(isShipped ? "Expédié" : "Reporté")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isShipped ? Color.statusSuccess : Color.statusNeutral)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, 4)
        .background(
            (isShipped ? Color.statusSuccess : Color.statusNeutral).opacity(0.15)
        )
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(
            (isShipped ? Color.statusSuccess : Color.statusNeutral).opacity(0.4),
            lineWidth: 1
        ))
    }
}

struct FillRateBarView: View {

    let label: String
    let rate: Double
    let threshold: Double
    let detail: String

    @State private var animatedRate: Double = 0

    private var barColor: Color {
        if rate >= threshold { return .statusSuccess }
        if rate >= threshold * 0.7 { return .statusWarning }
        return .statusDanger
    }

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(detail)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.textTertiary)
                Text(rate.percentFormatted)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(barColor)
                    .frame(minWidth: 44, alignment: .trailing)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DS.Radius.pill)
                        .fill(Color.surfaceSecondary)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: DS.Radius.pill)
                        .fill(
                            LinearGradient(
                                colors: gradientColors(for: animatedRate),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(animatedRate, 1.0), height: 8)
                        .shadow(color: animatedRate >= threshold ? Color.statusSuccess.opacity(0.4) : .clear,
                                radius: 6, x: 0, y: 0)

                    Rectangle()
                        .fill(Color.textTertiary.opacity(0.6))
                        .frame(width: 1.5, height: 12)
                        .offset(x: geo.size.width * threshold - 0.75, y: -2)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedRate = rate
            }
        }
        .onChange(of: rate) { _, newRate in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedRate = newRate
            }
        }
    }

    private func gradientColors(for r: Double) -> [Color] {
        if r < 0.5 { return [.statusDanger, .statusDanger.opacity(0.7)] }
        if r < threshold { return [.statusWarning, .statusWarning.opacity(0.7)] }
        return [.statusSuccess, .accentCyan]
    }
}
