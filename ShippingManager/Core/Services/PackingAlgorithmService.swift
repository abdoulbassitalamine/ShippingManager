import Foundation

protocol PackingAlgorithm {
    var name: String { get }
    var algorithmDescription: String { get }
    func pack(orders: [Order], config: ContainerConfig) -> ShippingPlan
}

final class GreedyPackingAlgorithm: PackingAlgorithm {

    let name = "Greedy (Rapide)"
    let algorithmDescription = "Trie les commandes par ratio prix/volume décroissant et remplit les conteneurs séquentiellement. Rapide et efficace pour des listes de taille modérée."

    func pack(orders: [Order], config: ContainerConfig) -> ShippingPlan {
        let priorityOrders = orders.filter { $0.isPriority }
            .sorted { $0.price / $0.volume > $1.price / $1.volume }
        let regularOrders  = orders.filter { !$0.isPriority }
            .sorted { $0.price / $0.volume > $1.price / $1.volume }

        var containers: [Container] = []
        var deferredOrders: [Order] = []
        var containerIndex = 1

        var priorityRemaining = priorityOrders
        while !priorityRemaining.isEmpty {
            var container = Container(id: UUID(), number: containerIndex, config: config)
            containerIndex += 1
            var stillPending: [Order] = []

            for order in priorityRemaining {
                if container.canAdd(order) {
                    container.loadedOrders.append(order)
                } else {
                    stillPending.append(order)
                }
            }

            if container.loadedOrders.isEmpty, let first = priorityRemaining.first {
                container.loadedOrders.append(first)
                stillPending = Array(priorityRemaining.dropFirst())
            }

            containers.append(container)
            priorityRemaining = stillPending
        }

        var regularRemaining = regularOrders
        for i in containers.indices {
            var updated = containers[i]
            var stillPending: [Order] = []
            for order in regularRemaining {
                if updated.canAdd(order) {
                    updated.loadedOrders.append(order)
                } else {
                    stillPending.append(order)
                }
            }
            containers[i] = updated
            regularRemaining = stillPending
        }

        while !regularRemaining.isEmpty {
            var container = Container(id: UUID(), number: containerIndex, config: config)
            containerIndex += 1
            var stillPending: [Order] = []

            for order in regularRemaining {
                if container.canAdd(order) {
                    container.loadedOrders.append(order)
                } else {
                    stillPending.append(order)
                }
            }

            if container.loadedOrders.isEmpty, let first = regularRemaining.first {
                deferredOrders.append(first)
                regularRemaining = Array(regularRemaining.dropFirst())
                continue
            }

            containers.append(container)
            regularRemaining = stillPending
        }

        return ShippingPlan(
            containers: containers,
            deferredOrders: deferredOrders,
            generatedAt: Date(),
            algorithmName: name
        )
    }
}

final class BinPackingAlgorithm: PackingAlgorithm {

    let name = "Bin Packing (Optimal)"
    let algorithmDescription = "Explore plusieurs combinaisons avec backtracking limité pour maximiser les recettes totales. Plus lent mais produit généralement de meilleurs résultats."

    private let maxIterations = 500

    func pack(orders: [Order], config: ContainerConfig) -> ShippingPlan {
        let priorityOrders = orders.filter { $0.isPriority }
            .sorted { $0.price > $1.price }
        let regularOrders  = orders.filter { !$0.isPriority }
            .sorted { $0.price > $1.price }

        var containers: [Container] = []
        var deferredOrders: [Order] = []
        var containerIndex = 1

        var priorityRemaining = priorityOrders
        while !priorityRemaining.isEmpty {
            var container = Container(id: UUID(), number: containerIndex, config: config)
            containerIndex += 1
            var stillPending: [Order] = []

            for order in priorityRemaining {
                if container.canAdd(order) {
                    container.loadedOrders.append(order)
                } else {
                    stillPending.append(order)
                }
            }

            if container.loadedOrders.isEmpty, let first = priorityRemaining.first {
                container.loadedOrders.append(first)
                stillPending = Array(priorityRemaining.dropFirst())
            }

            containers.append(container)
            priorityRemaining = stillPending
        }

        var regularRemaining = regularOrders

        for i in containers.indices {
            var updated = containers[i]
            let (packed, remaining) = binPackInto(container: &updated,
                                                   orders: regularRemaining,
                                                   maxIter: maxIterations / 2)
            if packed { containers[i] = updated }
            regularRemaining = remaining
        }

        while !regularRemaining.isEmpty {
            var container = Container(id: UUID(), number: containerIndex, config: config)
            containerIndex += 1

            let (_, remaining) = binPackInto(container: &container,
                                              orders: regularRemaining,
                                              maxIter: maxIterations)
            if container.loadedOrders.isEmpty {
                deferredOrders.append(regularRemaining[0])
                regularRemaining = Array(regularRemaining.dropFirst())
                continue
            }

            containers.append(container)
            regularRemaining = remaining
        }

        return ShippingPlan(
            containers: containers,
            deferredOrders: deferredOrders,
            generatedAt: Date(),
            algorithmName: name
        )
    }

    @discardableResult
    private func binPackInto(container: inout Container,
                              orders: [Order],
                              maxIter: Int) -> (Bool, [Order]) {
        guard !orders.isEmpty else { return (false, []) }

        var bestPrice: Double = -1
        var bestSelection: [Order] = []
        var iterations = 0

        var greedyContainer = Container(id: container.id,
                                        number: container.number,
                                        config: container.config)
        greedyContainer.loadedOrders = container.loadedOrders
        let greedySorted = orders.sorted { $0.price / ($0.volume + 0.001) > $1.price / ($1.volume + 0.001) }
        var greedySelection: [Order] = []
        for order in greedySorted {
            if greedyContainer.canAdd(order) {
                greedyContainer.loadedOrders.append(order)
                greedySelection.append(order)
            }
        }
        bestPrice = greedyContainer.totalRevenue
        bestSelection = greedySelection

        let shufflable = Array(orders.prefix(min(orders.count, 20)))
        while iterations < maxIter {
            iterations += 1
            let shuffled = shufflable.shuffled()
            var candidate = Container(id: container.id,
                                      number: container.number,
                                      config: container.config)
            candidate.loadedOrders = container.loadedOrders
            var selection: [Order] = []

            for order in shuffled {
                if candidate.canAdd(order) {
                    candidate.loadedOrders.append(order)
                    selection.append(order)
                }
            }

            if candidate.totalRevenue > bestPrice {
                bestPrice = candidate.totalRevenue
                bestSelection = selection
            }
        }

        let loadedIds = Set(container.loadedOrders.map { $0.id })
        let selectionIds = Set(bestSelection.map { $0.id })
        for order in bestSelection {
            if !loadedIds.contains(order.id) {
                container.loadedOrders.append(order)
            }
        }

        let remaining = orders.filter { !selectionIds.contains($0.id) }
        return (!bestSelection.isEmpty, remaining)
    }
}
