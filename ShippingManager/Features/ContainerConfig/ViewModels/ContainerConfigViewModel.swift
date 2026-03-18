import SwiftUI
import Observation

@Observable
@MainActor
final class ContainerConfigViewModel {

    var config: ContainerConfig {
        didSet { saveConfig() }
    }

    var selectedAlgorithm: AlgorithmType {
        didSet {
            UserDefaults.standard.set(selectedAlgorithm.rawValue, forKey: "selectedAlgorithm")
        }
    }

    init() {
        let maxWeight  = UserDefaults.standard.double(forKey: "maxWeight")
        let maxVolume  = UserDefaults.standard.double(forKey: "maxVolume")
        let threshold  = UserDefaults.standard.double(forKey: "minFillThreshold")
        let algRaw     = UserDefaults.standard.string(forKey: "selectedAlgorithm") ?? ""

        config = ContainerConfig(
            maxWeight: maxWeight > 0 ? maxWeight : 20_000,
            maxVolume: maxVolume > 0 ? maxVolume : 33.0,
            minFillThreshold: threshold > 0 ? threshold : 0.70
        )
        selectedAlgorithm = AlgorithmType(rawValue: algRaw) ?? .greedy
    }

    var currentAlgorithm: any PackingAlgorithm {
        switch selectedAlgorithm {
        case .greedy:     return GreedyPackingAlgorithm()
        case .binPacking: return BinPackingAlgorithm()
        }
    }

    func saveConfig() {
        UserDefaults.standard.set(config.maxWeight,         forKey: "maxWeight")
        UserDefaults.standard.set(config.maxVolume,         forKey: "maxVolume")
        UserDefaults.standard.set(config.minFillThreshold,  forKey: "minFillThreshold")
    }

    func resetToDefaults() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            config = ContainerConfig.default
            selectedAlgorithm = .greedy
        }
        saveConfig()
    }

    var isConfigValid: Bool {
        config.maxWeight > 0 &&
        config.maxVolume > 0 &&
        config.minFillThreshold >= 0 &&
        config.minFillThreshold <= 1
    }

    enum AlgorithmType: String, CaseIterable {
        case greedy     = "Greedy (Rapide)"
        case binPacking = "Bin Packing (Optimal)"

        var description: String {
            switch self {
            case .greedy:
                return "Algorithme glouton rapide. Trie les commandes par ratio prix/volume et remplit les conteneurs séquentiellement. Idéal pour de grandes listes."
            case .binPacking:
                return "Algorithme de bin packing avec backtracking. Explore plusieurs combinaisons pour maximiser les recettes. Plus lent mais plus précis."
            }
        }

        var icon: String {
            switch self {
            case .greedy:     return "bolt.fill"
            case .binPacking: return "cpu"
            }
        }
    }
}
