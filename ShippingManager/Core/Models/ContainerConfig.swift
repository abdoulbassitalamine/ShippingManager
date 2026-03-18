import Foundation

struct ContainerConfig: Codable, Equatable {
    var maxWeight: Double = 20_000
    var maxVolume: Double = 33.0
    var minFillThreshold: Double = 0.70

    static let `default` = ContainerConfig()
}
