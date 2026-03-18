import SwiftUI

struct ContainerConfigView: View {

    @State var viewModel: ContainerConfigViewModel
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DS.Spacing.lg) {
                        containerLimitsSection
                        fillThresholdSection
                        algorithmSection
                        resetButton
                    }
                    .padding(DS.Spacing.md)
                }
            }
            .navigationTitle("Conteneurs")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Réinitialiser", isPresented: $showResetAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Réinitialiser", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            } message: {
                Text("Les paramètres seront remis aux valeurs par défaut.")
            }
        }
    }

    private var containerLimitsSection: some View {
        configCard(title: "Limites du conteneur", icon: "shippingbox.fill") {
            VStack(spacing: DS.Spacing.lg) {
                sliderField(
                    label: "Poids maximum",
                    value: $viewModel.config.maxWeight,
                    range: 1000...50_000,
                    step: 500,
                    unit: "kg",
                    color: .accentBlue
                )

                Divider().background(Color.surfaceBorder)

                sliderField(
                    label: "Volume maximum",
                    value: $viewModel.config.maxVolume,
                    range: 5...100,
                    step: 0.5,
                    unit: "m³",
                    color: .accentCyan
                )
            }
        }
    }

    private var fillThresholdSection: some View {
        configCard(title: "Seuil de remplissage", icon: "chart.bar.fill") {
            VStack(spacing: DS.Spacing.md) {
                HStack {
                    Text("Seuil minimum")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Text(viewModel.config.minFillThreshold.percentFormatted)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(thresholdColor)
                }

                Slider(value: $viewModel.config.minFillThreshold,
                       in: 0.3...1.0,
                       step: 0.05)
                    .tint(thresholdColor)

                HStack {
                    Label("Un conteneur sous ce seuil sera reporté (sauf prioritaires)",
                          systemImage: "info.circle")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textTertiary)
                }
            }
        }
    }

    private var algorithmSection: some View {
        configCard(title: "Algorithme de remplissage", icon: "cpu") {
            VStack(spacing: DS.Spacing.md) {
                Picker("Algorithme", selection: $viewModel.selectedAlgorithm) {
                    ForEach(ContainerConfigViewModel.AlgorithmType.allCases, id: \.self) { algo in
                        Text(algo.rawValue).tag(algo)
                    }
                }
                .pickerStyle(.segmented)

                HStack(alignment: .top, spacing: DS.Spacing.sm) {
                    Image(systemName: viewModel.selectedAlgorithm.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.accentBlue)
                        .frame(width: 24)

                    Text(viewModel.selectedAlgorithm.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DS.Spacing.sm)
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                .animation(.easeOut(duration: 0.2), value: viewModel.selectedAlgorithm)
            }
        }
    }

    private var resetButton: some View {
        Button {
            showResetAlert = true
        } label: {
            Label("Réinitialiser les valeurs par défaut", systemImage: "arrow.counterclockwise")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.statusDanger)
                .frame(maxWidth: .infinity)
                .padding(DS.Spacing.md)
                .background(Color.statusDanger.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.md)
                    .strokeBorder(Color.statusDanger.opacity(0.3), lineWidth: 1))
        }
    }

    private var thresholdColor: Color {
        let t = viewModel.config.minFillThreshold
        if t < 0.5 { return .statusWarning }
        if t < 0.8 { return .accentBlue }
        return .statusSuccess
    }

    private func configCard<Content: View>(title: String,
                                           icon: String,
                                           @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.accentBlue)
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .tracking(0.8)
            }

            content()
                .padding(DS.Spacing.md)
                .background(Color.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .strokeBorder(Color.surfaceBorder, lineWidth: 1))
                .cardShadow()
        }
    }

    private func sliderField(label: String,
                              value: Binding<Double>,
                              range: ClosedRange<Double>,
                              step: Double,
                              unit: String,
                              color: Color) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text("\(value.wrappedValue.formatted(.number.precision(.fractionLength(unit == "m³" ? 1 : 0)))) \(unit)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            Slider(value: value, in: range, step: step)
                .tint(color)
        }
    }
}
