import SwiftUI

struct OrderListView: View {

    @State var viewModel: OrderListViewModel
    let containerConfig: ContainerConfig

    @State private var showCountPicker = false
    @State private var animationTrigger = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                priorityFilterBar

                if viewModel.filteredOrders.isEmpty {
                    emptyState
                } else {
                    orderList
                }
            }
        }
        .navigationTitle("Commandes")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Rechercher une commande…")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                sortMenu
            }
            ToolbarItem(placement: .topBarTrailing) {
                regenerateButton
            }
        }
    }

    private var priorityFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                filterChip(label: "Tous", icon: "line.3.horizontal.decrease.circle",
                           isActive: viewModel.selectedPriority == nil) {
                    viewModel.selectedPriority = nil
                }

                ForEach(Order.Priority.allCases, id: \.self) { priority in
                    filterChip(label: priority.rawValue,
                               icon: priority.icon,
                               color: priority.color,
                               isActive: viewModel.selectedPriority == priority) {
                        viewModel.togglePriorityFilter(priority)
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
        }
        .background(Color.surfacePrimary)
        .overlay(alignment: .bottom) {
            Divider().background(Color.surfaceBorder)
        }
    }

    private var orderList: some View {
        ScrollView {
            HStack {
                Text("\(viewModel.filteredOrders.count) commande(s)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .tracking(0.8)
                Spacer()
                Text("Total : \(viewModel.filteredOrders.reduce(0) { $0 + $1.price }.euroFormatted)")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.statusSuccess)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.top, DS.Spacing.md)

            LazyVStack(spacing: DS.Spacing.sm) {
                ForEach(Array(viewModel.filteredOrders.enumerated()), id: \.element.id) { index, order in
                    NavigationLink(destination: OrderDetailView(order: order,
                                                                containerConfig: containerConfig)) {
                        OrderRowView(order: order)
                    }
                    .buttonStyle(.plain)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8)
                            .delay(Double(index) * 0.03),
                        value: animationTrigger
                    )
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.lg)
        }
        .opacity(viewModel.isRegenerating ? 0 : 1)
        .animation(.easeOut(duration: 0.2), value: viewModel.isRegenerating)
        .onChange(of: viewModel.orders) { _, _ in
            animationTrigger.toggle()
        }
        .refreshable {
            await viewModel.generateOrders()
        }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()
            Image(systemName: "shippingbox")
                .font(.system(size: 60))
                .foregroundStyle(Color.textTertiary)
            Text("Aucune commande")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
            Text("Utilisez le bouton \"Régénérer\" pour créer une liste de commandes.")
                .font(.system(size: 14))
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.xl)
            Spacer()
        }
    }

    private var regenerateButton: some View {
        Button {
            Task { await viewModel.generateOrders() }
        } label: {
            HStack(spacing: DS.Spacing.xs) {
                if viewModel.isRegenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text("Régénérer")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(Color.accentBlue)
            .clipShape(Capsule())
        }
        .disabled(viewModel.isRegenerating)
    }

    private var sortMenu: some View {
        Menu {
            Picker("Trier par", selection: $viewModel.sortOption) {
                ForEach(OrderListViewModel.SortOption.allCases, id: \.self) { option in
                    Label(option.rawValue, systemImage: option.icon)
                        .tag(option as OrderListViewModel.SortOption)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
                .foregroundStyle(Color.accentBlue)
                .font(.system(size: 18))
        }
    }

    private func filterChip(label: String,
                             icon: String,
                             color: Color = .accentBlue,
                             isActive: Bool,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isActive ? .white : color)
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.xs + 2)
            .background(isActive ? color : color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(isActive ? color : color.opacity(0.3), lineWidth: 1))
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }
}

