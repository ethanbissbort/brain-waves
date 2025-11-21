//
//  AudioEffectsControl.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct AudioEffectsControl: View {
    @ObservedObject var effectsManager: AudioEffectsManager
    @State private var expandedEffect: UUID?
    @State private var showingPresets = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "waveform.path.badge.plus")
                    .foregroundColor(.purple)
                Text("Audio Effects")
                    .font(.headline)

                Spacer()

                Button(action: {
                    showingPresets = true
                }) {
                    Label("Presets", systemImage: "sparkles")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                }
            }

            // Effects List
            if effectsManager.effects.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path.badge.minus")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No effects available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(effectsManager.effects) { effect in
                    EffectRow(
                        effect: effect,
                        isExpanded: expandedEffect == effect.id,
                        onToggle: {
                            effectsManager.toggleEffect(effect.id)
                            HapticManager.shared.playSelection()
                        },
                        onExpand: {
                            withAnimation {
                                if expandedEffect == effect.id {
                                    expandedEffect = nil
                                } else {
                                    expandedEffect = effect.id
                                }
                            }
                        },
                        onParameterChange: { parameters in
                            effectsManager.updateEffectParameters(effect.id, parameters: parameters)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingPresets) {
            EffectPresetsSheet(effectsManager: effectsManager, isPresented: $showingPresets)
        }
    }
}

// MARK: - Effect Row

struct EffectRow: View {
    let effect: AudioEffectConfig
    let isExpanded: Bool
    let onToggle: () -> Void
    let onExpand: () -> Void
    let onParameterChange: (AudioEffectConfig.EffectParameters) -> Void

    @State private var localParameters: AudioEffectConfig.EffectParameters

    init(
        effect: AudioEffectConfig,
        isExpanded: Bool,
        onToggle: @escaping () -> Void,
        onExpand: @escaping () -> Void,
        onParameterChange: @escaping (AudioEffectConfig.EffectParameters) -> Void
    ) {
        self.effect = effect
        self.isExpanded = isExpanded
        self.onToggle = onToggle
        self.onExpand = onExpand
        self.onParameterChange = onParameterChange
        _localParameters = State(initialValue: effect.parameters)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Button(action: onToggle) {
                    Image(systemName: effect.isEnabled ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(effect.isEnabled ? .green : .secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: effect.effectType.icon)
                            .foregroundColor(effect.isEnabled ? .purple : .secondary)
                        Text(effect.effectType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(effect.isEnabled ? .primary : .secondary)
                    }

                    Text(effect.effectType.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onExpand) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.purple)
                }
            }

            // Parameters (expanded)
            if isExpanded && effect.isEnabled {
                Divider()

                switch effect.effectType {
                case .reverb:
                    reverbParameters
                case .delay:
                    delayParameters
                case .lowPassFilter:
                    filterParameters(title: "Low-Pass Cutoff")
                case .highPassFilter:
                    filterParameters(title: "High-Pass Cutoff")
                case .bandPassFilter:
                    bandPassParameters
                case .distortion:
                    distortionParameters
                case .eq:
                    eqParameters
                }
            }
        }
        .padding()
        .background(effect.isEnabled ? Color(.systemGray6) : Color(.systemGray5))
        .cornerRadius(10)
        .opacity(effect.isEnabled ? 1.0 : 0.6)
    }

    // MARK: - Parameter Views

    private var reverbParameters: some View {
        VStack(spacing: 12) {
            ParameterSlider(
                title: "Mix",
                value: $localParameters.reverbMix,
                range: 0...1,
                format: "%.0f%%",
                multiplier: 100,
                onChange: { onParameterChange(localParameters) }
            )

            ParameterSlider(
                title: "Room Size",
                value: $localParameters.reverbSize,
                range: 0...1,
                format: "%.0f%%",
                multiplier: 100,
                onChange: { onParameterChange(localParameters) }
            )
        }
    }

    private var delayParameters: some View {
        VStack(spacing: 12) {
            ParameterSlider(
                title: "Delay Time",
                value: $localParameters.delayTime,
                range: 0.1...2.0,
                format: "%.2f s",
                onChange: { onParameterChange(localParameters) }
            )

            ParameterSlider(
                title: "Mix",
                value: $localParameters.delayMix,
                range: 0...1,
                format: "%.0f%%",
                multiplier: 100,
                onChange: { onParameterChange(localParameters) }
            )

            ParameterSlider(
                title: "Feedback",
                value: $localParameters.delayFeedback,
                range: 0...0.9,
                format: "%.0f%%",
                multiplier: 100,
                onChange: { onParameterChange(localParameters) }
            )
        }
    }

    private func filterParameters(title: String) -> some View {
        ParameterSlider(
            title: title,
            value: $localParameters.cutoffFrequency,
            range: 20...20000,
            format: "%.0f Hz",
            onChange: { onParameterChange(localParameters) }
        )
    }

    private var bandPassParameters: some View {
        VStack(spacing: 12) {
            ParameterSlider(
                title: "Center Frequency",
                value: $localParameters.cutoffFrequency,
                range: 20...20000,
                format: "%.0f Hz",
                onChange: { onParameterChange(localParameters) }
            )

            ParameterSlider(
                title: "Bandwidth",
                value: $localParameters.bandwidth,
                range: 100...2000,
                format: "%.0f Hz",
                onChange: { onParameterChange(localParameters) }
            )
        }
    }

    private var distortionParameters: some View {
        VStack(spacing: 12) {
            ParameterSlider(
                title: "Mix",
                value: $localParameters.distortionMix,
                range: 0...1,
                format: "%.0f%%",
                multiplier: 100,
                onChange: { onParameterChange(localParameters) }
            )

            ParameterSlider(
                title: "Amount",
                value: $localParameters.distortionAmount,
                range: 0...1,
                format: "%.0f%%",
                multiplier: 100,
                onChange: { onParameterChange(localParameters) }
            )
        }
    }

    private var eqParameters: some View {
        VStack(spacing: 12) {
            ParameterSlider(
                title: "Low (80 Hz)",
                value: $localParameters.eqLowGain,
                range: -12...12,
                format: "%+.1f dB",
                onChange: { onParameterChange(localParameters) }
            )

            ParameterSlider(
                title: "Mid (1 kHz)",
                value: $localParameters.eqMidGain,
                range: -12...12,
                format: "%+.1f dB",
                onChange: { onParameterChange(localParameters) }
            )

            ParameterSlider(
                title: "High (8 kHz)",
                value: $localParameters.eqHighGain,
                range: -12...12,
                format: "%+.1f dB",
                onChange: { onParameterChange(localParameters) }
            )
        }
    }
}

// MARK: - Parameter Slider

struct ParameterSlider: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let format: String
    var multiplier: Float = 1.0
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: format, value * multiplier))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
            }

            Slider(value: $value, in: range)
                .accentColor(.purple)
                .onChange(of: value) { _ in
                    onChange()
                }
        }
    }
}

// MARK: - Effect Presets Sheet

struct EffectPresetsSheet: View {
    @ObservedObject var effectsManager: AudioEffectsManager
    @Binding var isPresented: Bool

    private let presets: [(name: String, description: String, icon: String, effects: () -> [AudioEffectConfig])] = [
        (
            "Ambient",
            "Reverb and low-pass for spacious sound",
            "cloud.fill",
            AudioEffectsManager.ambientPreset
        ),
        (
            "Deep Space",
            "Heavy reverb, delay, and filtering",
            "sparkles",
            AudioEffectsManager.deepSpacePreset
        ),
        (
            "Crystal Clear",
            "High-pass and EQ for clarity",
            "waveform.path",
            AudioEffectsManager.crystalClearPreset
        ),
        (
            "Warm",
            "Low-pass and EQ for warmth",
            "sun.max.fill",
            AudioEffectsManager.warmPreset
        )
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Effect Presets")) {
                    ForEach(presets, id: \.name) { preset in
                        Button(action: {
                            loadPreset(preset.effects())
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: preset.icon)
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                    .frame(width: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(preset.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                Section(header: Text("Tips")) {
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(text: "Effects are applied in order from top to bottom")
                        InfoRow(text: "Start with subtle settings and adjust to taste")
                        InfoRow(text: "Reverb and delay can make tones more relaxing")
                        InfoRow(text: "Filters can help reduce harshness")
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Effect Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func loadPreset(_ effects: [AudioEffectConfig]) {
        effectsManager.effects = effects
        isPresented = false
        HapticManager.shared.playSuccess()
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    AudioEffectsControl(effectsManager: AudioEffectsManager())
        .padding()
}
