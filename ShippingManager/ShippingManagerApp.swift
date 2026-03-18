import SwiftUI

@main
struct ShippingManagerApp: App {

    @State private var orderListViewModel    = OrderListViewModel()
    @State private var containerConfigViewModel = ContainerConfigViewModel()
    @State private var shippingPlanViewModel = ShippingPlanViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Commandes", systemImage: "shippingbox") {
                    NavigationStack {
                        OrderListView(
                            viewModel: orderListViewModel,
                            containerConfig: containerConfigViewModel.config
                        )
                    }
                }

                Tab("Conteneurs", systemImage: "slider.horizontal.3") {
                    ContainerConfigView(viewModel: containerConfigViewModel)
                }

                Tab("Expédition", systemImage: "ferry") {
                    ShippingPlanView(
                        viewModel: shippingPlanViewModel,
                        orders: orderListViewModel.orders,
                        configViewModel: containerConfigViewModel
                    )
                }
            }
            .tint(Color.accentBlue)
            .preferredColorScheme(.dark)
        }
    }
}
