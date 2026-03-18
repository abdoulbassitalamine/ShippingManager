import SwiftUI

struct OrderDetailView: View {

    let order: Order
    let containerConfig: ContainerConfig

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.lg) {
                headerSection

                characteristicsSection

                gaugesSection

                statusSection
            }
            .padding(DS.Spacing.md)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(order.orderNumber)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(order.description)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)

                    Text("Créée le \(order.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                PriorityBadgeView(priority: order.priority)
            }

            Text(order.price.euroFormatted)
                .font(.system(size: 34, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.statusSuccess)
        }
        .padding(DS.Spacing.md)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg)
            .strokeBorder(Color.surfaceBorder, lineWidth: 1))
        .cardShadow()
    }

    private var characteristicsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            sectionLabel("Caractéristiques")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                      spacing: DS.Spacing.sm) {
                MetricTileView(icon: "scalemass.fill",
                               label: "Poids",
                               value: order.weight.kgFormatted,
                               color: .accentBlue)

                MetricTileView(icon: "cube.fill",
                               label: "Volume",
                               value: order.volume.m3Formatted,
                               color: .accentCyan)

                MetricTileView(icon: "number",
                               label: "N° Commande",
                               value: order.orderNumber,
                               color: .textSecondary)

                MetricTileView(icon: order.fragility.icon,
                               label: "Fragilité",
                               value: order.fragility.rawValue,
                               color: order.fragility == .normal ? .textSecondary : .statusWarning)
            }
        }
    }

    private var gaugesSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            sectionLabel("Occupation du conteneur")

            VStack(spacing: DS.Spacing.md) {
                GaugeRowView(label: "Poids",
                             value: order.weight,
                             max: containerConfig.maxWeight,
                             unit: "kg",
                             color: .accentBlue)

                GaugeRowView(label: "Volume",
                             value: order.volume,
                             max: containerConfig.maxVolume,
                             unit: "m³",
                             color: .accentCyan)
            }
            .padding(DS.Spacing.md)
            .background(Color.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg)
                .strokeBorder(Color.surfaceBorder, lineWidth: 1))
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            sectionLabel("Statut")

            HStack(spacing: DS.Spacing.sm) {
                VStack(spacing: DS.Spacing.sm) {
                    Image(systemName: order.priority.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(order.priority.color)
                    Text("Priorité \(order.priority.rawValue)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DS.Spacing.md)
                .background(order.priority.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.md)
                    .strokeBorder(order.priority.color.opacity(0.3), lineWidth: 1))

                VStack(spacing: DS.Spacing.sm) {
                    Image(systemName: order.fragility.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(order.fragility == .normal ? Color.textSecondary : Color.statusWarning)
                    Text(order.fragility.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DS.Spacing.md)
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.md)
                    .strokeBorder(Color.surfaceBorder, lineWidth: 1))
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.textSecondary)
            .tracking(0.8)
    }
}

private struct MetricTileView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textSecondary)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.md)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md)
            .strokeBorder(Color.surfaceBorder, lineWidth: 1))
    }
}

private struct GaugeRowView: View {
    let label: String
    let value: Double
    let max: Double
    let unit: String
    let color: Color

    private var ratio: Double { max > 0 ? min(value / max, 1.0) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("\(value.formatted(.number.precision(.fractionLength(1)))) / \(max.formatted(.number.precision(.fractionLength(0)))) \(unit)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.textSecondary)
            }

            Gauge(value: ratio) {
                EmptyView()
            }
            .gaugeStyle(.linearCapacity)
            .tint(color)
        }
    }
}
