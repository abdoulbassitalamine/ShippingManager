import Foundation

final class OrderGeneratorService {

    private let merchandiseNames: [String] = [
        "Électronique grand public", "Composants automobiles", "Mobilier de bureau",
        "Équipements médicaux", "Textiles industriels", "Outillage professionnel",
        "Pièces de rechange", "Matériaux de construction", "Produits chimiques sûrs",
        "Équipements sportifs", "Instruments de musique", "Vaisselle et céramiques",
        "Livres et archives", "Matériel agricole", "Équipements de laboratoire",
        "Câbles et connecteurs", "Systèmes de sécurité", "Emballages industriels",
        "Fournitures scolaires", "Appareils électroménagers", "Peintures et revêtements",
        "Matériel informatique", "Équipements de cuisine", "Vêtements de travail",
        "Matériel de bureau", "Systèmes hydrauliques", "Composants électroniques",
        "Équipements de levage", "Produits d'entretien", "Accessoires automobiles"
    ]

    func generateOrders(count: Int = 20) -> [Order] {
        var orders: [Order] = []
        for i in 1...max(1, count) {
            orders.append(makeOrder(index: i))
        }
        return orders
    }

    private func makeOrder(index: Int) -> Order {
        let weight = Double.random(in: 50...5000).rounded(to: 1)
        let volume = Double.random(in: 0.1...10.0).rounded(to: 2)
        let price  = Double.random(in: 100...50_000).rounded(to: 2)

        return Order(
            id: UUID(),
            orderNumber: String(format: "CMD-%04d", index),
            weight: weight,
            volume: volume,
            price: price,
            priority: randomPriority(),
            fragility: randomFragility(),
            description: merchandiseNames.randomElement() ?? "Marchandise diverse",
            createdAt: Date()
        )
    }

    private func randomPriority() -> Order.Priority {
        let r = Int.random(in: 1...100)
        switch r {
        case 1...5:   return .urgent
        case 6...20:  return .high
        case 21...40: return .low
        default:      return .normal
        }
    }

    private func randomFragility() -> Order.Fragility {
        let r = Int.random(in: 1...100)
        switch r {
        case 1...10:  return .veryFragile
        case 11...30: return .fragile
        default:      return .normal
        }
    }
}

private extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
