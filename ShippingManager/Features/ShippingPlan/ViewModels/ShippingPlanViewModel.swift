import SwiftUI
import Observation

@Observable
@MainActor
final class ShippingPlanViewModel {

    var shippingPlan: ShippingPlan? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let planService: ShippingPlanService

    init(planService: ShippingPlanService = ShippingPlanService()) {
        self.planService = planService
    }

    func generatePlan(from orders: [Order],
                      config: ContainerConfig,
                      algorithm: any PackingAlgorithm) {
        guard !orders.isEmpty else {
            errorMessage = "Aucune commande disponible."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            let plan = await Task.detached(priority: .userInitiated) {
                self.planService.buildPlan(from: orders,
                                           config: config,
                                           algorithm: algorithm)
            }.value

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.shippingPlan = plan
                self.isLoading = false
            }

            let generator = await UINotificationFeedbackGenerator()
            await generator.notificationOccurred(.success)
        }
    }

    func reset() {
        withAnimation {
            shippingPlan = nil
            errorMessage = nil
        }
    }
}
