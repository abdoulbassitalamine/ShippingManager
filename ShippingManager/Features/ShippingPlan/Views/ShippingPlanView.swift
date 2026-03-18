import SwiftUI

struct ShippingPlanView: View {

    @State var viewModel: ShippingPlanViewModel
    let orders: [Order]
    let configViewModel: ContainerConfigViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingState
                } else if let plan = viewModel.shippingPlan {
                    planContent(plan: plan)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Expédition")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if viewModel.shippingPlan != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.reset()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            VStack(spacing: DS.Spacing.lg) {
                Image(systemName: "shippingbox.and.arrow.backward")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentBlue.opacity(0.6))

                VStack(spacing: DS.Spacing.sm) {
                    Text("Plan d'expédition")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)

                    Text("Générez le plan pour optimiser le chargement de \(orders.count) commandes dans les conteneurs.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Spacing.xl)
                }
            }

            Spacer()

            generateButton

            if orders.isEmpty {
                Text("Ajoutez des commandes dans l'onglet Commandes d'abord.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Spacing.xl)
            }
        }
        .padding(DS.Spacing.md)
    }

    private var loadingState: some View {
        VStack(spacing: DS.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.accentBlue)

            Text("Optimisation en cours…")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)

            Text("Algorithme : \(configViewModel.selectedAlgorithm.rawValue)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textTertiary)
        }
    }

    private func planContent(plan: ShippingPlan) -> some View {
        ScrollView {
            VStack(spacing: DS.Spacing.lg) {
                ShippingStatsView(plan: plan)
                    .padding(.horizontal, DS.Spacing.md)

                if !plan.shippedContainers.isEmpty {
                    sectionHeader("Conteneurs expédiés",
                                  icon: "checkmark.seal.fill",
                                  color: .statusSuccess,
                                  count: plan.shippedContainers.count)

                    ForEach(Array(plan.shippedContainers.enumerated()), id: \.element.id) { index, container in
                        ContainerCardView(container: container)
                            .padding(.horizontal, DS.Spacing.md)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.1),
                                value: plan.shippedContainers.count
                            )
                    }
                }

                if !plan.deferredContainers.isEmpty {
                    sectionHeader("Conteneurs reportés",
                                  icon: "clock.badge.xmark",
                                  color: .statusWarning,
                                  count: plan.deferredContainers.count)

                    ForEach(plan.deferredContainers) { container in
                        ContainerCardView(container: container)
                            .padding(.horizontal, DS.Spacing.md)
                            .opacity(0.7)
                    }
                }

                if !plan.deferredOrders.isEmpty {
                    sectionHeader("Commandes en attente",
                                  icon: "hourglass",
                                  color: .statusNeutral,
                                  count: plan.deferredOrders.count)

                    deferredOrdersList(plan.deferredOrders)
                }

                generateButton
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.bottom, DS.Spacing.lg)
            }
            .padding(.top, DS.Spacing.md)
        }
    }

    private func sectionHeader(_ title: String, icon: String, color: Color, count: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 14))
            Text(title.uppercased())
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .tracking(0.8)
            Spacer()
            Text("\(count)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, 2)
                .background(color.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, DS.Spacing.md)
    }

    private func deferredOrdersList(_ orders: [Order]) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            ForEach(orders) { order in
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: order.priority.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(order.priority.color)
                        .frame(width: 20)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(order.orderNumber)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.textPrimary)
                        Text(order.description)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(order.price.euroFormatted)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.textPrimary)
                        Text(order.weight.kgFormatted)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(DS.Spacing.sm)
                .background(Color.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .strokeBorder(Color.surfaceBorder, lineWidth: 1))
                .padding(.horizontal, DS.Spacing.md)
            }
        }
    }

    private var generateButton: some View {
        Button {
            viewModel.generatePlan(
                from: orders,
                config: configViewModel.config,
                algorithm: configViewModel.currentAlgorithm
            )
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "shippingbox.fill")
                Text(viewModel.shippingPlan == nil ? "Générer le plan d'expédition" : "Recalculer")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.md)
            .background(
                orders.isEmpty
                    ? AnyShapeStyle(Color.textTertiary)
                    : AnyShapeStyle(LinearGradient(colors: [Color.accentBlue, Color.accentCyan.opacity(0.8)],
                                                   startPoint: .leading, endPoint: .trailing))
            )
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .glowShadow()
        }
        .disabled(orders.isEmpty || viewModel.isLoading)
    }
}
