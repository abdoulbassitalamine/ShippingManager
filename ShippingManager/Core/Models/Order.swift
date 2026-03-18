import Foundation

struct Order: Identifiable, Hashable, Codable {
    let id: UUID
    let orderNumber: String
    let weight: Double
    let volume: Double
    let price: Double
    let priority: Priority
    let fragility: Fragility
    let description: String
    let createdAt: Date

    var isPriority: Bool { priority == .high || priority == .urgent }

    enum Priority: String, CaseIterable, Codable {
        case low    = "Basse"
        case normal = "Normale"
        case high   = "Haute"
        case urgent = "Urgente"

        var colorName: String {
            switch self {
            case .low:    return "priorityLow"
            case .normal: return "priorityNormal"
            case .high:   return "priorityHigh"
            case .urgent: return "priorityUrgent"
            }
        }

        var icon: String {
            switch self {
            case .low:    return "arrow.down.circle"
            case .normal: return "minus.circle"
            case .high:   return "exclamationmark.circle"
            case .urgent: return "flame.fill"
            }
        }

        var sortOrder: Int {
            switch self {
            case .urgent: return 0
            case .high:   return 1
            case .normal: return 2
            case .low:    return 3
            }
        }
    }

    enum Fragility: String, CaseIterable, Codable {
        case normal      = "Standard"
        case fragile     = "Fragile"
        case veryFragile = "Très fragile"

        var icon: String {
            switch self {
            case .normal:      return "shippingbox"
            case .fragile:     return "exclamationmark.triangle"
            case .veryFragile: return "hand.raised"
            }
        }
    }
}
