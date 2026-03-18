import Foundation

struct ShippingPlan {
    let containers: [Container]
    let deferredOrders: [Order]
    let generatedAt: Date
    let algorithmName: String

    var shippedContainers: [Container]  { containers.filter { $0.willBeShipped } }
    var deferredContainers: [Container] { containers.filter { !$0.willBeShipped } }

    var totalRevenue: Double {
        shippedContainers.reduce(0) { $0 + $1.totalRevenue }
    }

    var totalOrders: Int {
        containers.reduce(0) { $0 + $1.loadedOrders.count }
    }

    var averageFillRate: Double {
        guard !shippedContainers.isEmpty else { return 0 }
        return shippedContainers.reduce(0) { $0 + $1.fillRate } / Double(shippedContainers.count)
    }

    var totalShippedOrders: Int {
        shippedContainers.reduce(0) { $0 + $1.loadedOrders.count }
    }

    var totalDeferredOrders: Int {
        deferredContainers.reduce(0) { $0 + $1.loadedOrders.count } + deferredOrders.count
    }
}
