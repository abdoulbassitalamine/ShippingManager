import Foundation

struct Container: Identifiable {
    let id: UUID
    let number: Int
    var loadedOrders: [Order] = []
    let config: ContainerConfig

    var totalWeight: Double  { loadedOrders.reduce(0) { $0 + $1.weight } }
    var totalVolume: Double  { loadedOrders.reduce(0) { $0 + $1.volume } }
    var totalRevenue: Double { loadedOrders.reduce(0) { $0 + $1.price  } }

    var weightFillRate: Double { config.maxWeight > 0 ? totalWeight / config.maxWeight : 0 }
    var volumeFillRate: Double { config.maxVolume > 0 ? totalVolume / config.maxVolume : 0 }

    var fillRate: Double { max(weightFillRate, volumeFillRate) }

    var isReadyToShip: Bool   { fillRate >= config.minFillThreshold }
    var hasPriorityOrders: Bool { loadedOrders.contains { $0.isPriority } }

    var willBeShipped: Bool { isReadyToShip || hasPriorityOrders }

    var remainingWeight: Double { config.maxWeight - totalWeight }
    var remainingVolume: Double { config.maxVolume - totalVolume }

    func canAdd(_ order: Order) -> Bool {
        totalWeight + order.weight <= config.maxWeight &&
        totalVolume + order.volume <= config.maxVolume
    }
}
