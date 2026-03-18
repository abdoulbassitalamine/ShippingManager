import Foundation

final class ShippingPlanService {

    func buildPlan(from orders: [Order],
                   config: ContainerConfig,
                   algorithm: any PackingAlgorithm) -> ShippingPlan {
        guard !orders.isEmpty else {
            return ShippingPlan(containers: [],
                                deferredOrders: [],
                                generatedAt: Date(),
                                algorithmName: algorithm.name)
        }
        return algorithm.pack(orders: orders, config: config)
    }
}
