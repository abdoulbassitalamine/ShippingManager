import SwiftUI
import Observation

@Observable
@MainActor
final class OrderListViewModel {

    var orders: [Order] = []
    var searchText: String = ""
    var selectedPriority: Order.Priority? = nil
    var sortOption: SortOption = .byPrice
    var isRegenerating: Bool = false
    var orderCount: Int = 20

    private let generatorService: OrderGeneratorService

    init(generatorService: OrderGeneratorService = OrderGeneratorService()) {
        self.generatorService = generatorService
        generateOrders()
    }

    var filteredOrders: [Order] {
        var result = orders

        if !searchText.isEmpty {
            result = result.filter {
                $0.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let priority = selectedPriority {
            result = result.filter { $0.priority == priority }
        }

        result.sort { lhs, rhs in
            switch sortOption {
            case .byPrice:    return lhs.price > rhs.price
            case .byWeight:   return lhs.weight > rhs.weight
            case .byVolume:   return lhs.volume > rhs.volume
            case .byPriority: return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
        }

        return result
    }

    func generateOrders(count: Int? = nil) {
        let n = count ?? orderCount
        withAnimation(.easeOut(duration: 0.2)) {
            isRegenerating = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            orders = generatorService.generateOrders(count: n)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isRegenerating = false
            }
        }
    }

    func deleteOrder(at offsets: IndexSet) {
        let filtered = filteredOrders
        let idsToDelete = offsets.map { filtered[$0].id }
        orders.removeAll { idsToDelete.contains($0.id) }
    }

    func togglePriorityFilter(_ priority: Order.Priority) {
        if selectedPriority == priority {
            selectedPriority = nil
        } else {
            selectedPriority = priority
        }
    }

    enum SortOption: String, CaseIterable {
        case byPrice    = "Prix"
        case byWeight   = "Poids"
        case byVolume   = "Volume"
        case byPriority = "Priorité"

        var icon: String {
            switch self {
            case .byPrice:    return "eurosign.circle"
            case .byWeight:   return "scalemass"
            case .byVolume:   return "cube"
            case .byPriority: return "flame"
            }
        }
    }
}
