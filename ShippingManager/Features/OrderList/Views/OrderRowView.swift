import SwiftUI

struct OrderRowView: View {

    let order: Order
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            RoundedRectangle(cornerRadius: DS.Radius.pill)
                .fill(order.priority.color)
                .frame(width: 3)
                .padding(.vertical, DS.Spacing.xs)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text(order.orderNumber)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    PriorityBadgeView(priority: order.priority)
                }

                Text(order.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)

                HStack(spacing: DS.Spacing.md) {
                    Label(order.price.euroFormatted,
                          systemImage: "eurosign.circle.fill")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.statusSuccess)

                    Spacer()

                    HStack(spacing: DS.Spacing.sm) {
                        Label(order.weight.kgFormatted, systemImage: "scalemass")
                        Label(order.volume.m3Formatted, systemImage: "cube")
                    }
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)

                    Image(systemName: order.fragility.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(
                            order.fragility == .normal ? Color.textTertiary : Color.statusWarning
                        )
                }
            }
        }
        .padding(.vertical, DS.Spacing.sm)
        .padding(.horizontal, DS.Spacing.sm)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .strokeBorder(Color.surfaceBorder, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .cardShadow()
    }
}

struct PriorityBadgeView: View {

    let priority: Order.Priority
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.icon)
                .font(.system(size: 10, weight: .semibold))
            Text(priority.rawValue)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(priority.color)
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, 4)
        .background(priority.color.opacity(0.15))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(priority.color.opacity(0.4), lineWidth: 1))
        .opacity(isPulsing ? 0.6 : 1.0)
        .onAppear {
            if priority == .urgent {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}
