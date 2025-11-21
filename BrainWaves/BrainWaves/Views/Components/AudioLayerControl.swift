//
//  AudioLayerControl.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct AudioLayerControl: View {
    @ObservedObject var layerManager: MultiLayerAudioManager
    @State private var showingAddLayer = false
    @State private var showingPresetSelector = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .foregroundColor(.blue)
                Text("Audio Layers")
                    .font(.headline)

                Spacer()

                Text("\(layerManager.layers.count) layer\(layerManager.layers.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Master Volume
            if !layerManager.layers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.blue)
                        Text("Master Volume")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(layerManager.masterVolume * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Slider(value: Binding(
                        get: { layerManager.masterVolume },
                        set: { layerManager.setMasterVolume($0) }
                    ), in: 0...1)
                    .accentColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            // Layers List
            if layerManager.layers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No audio layers")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Add layers to create complex soundscapes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(layerManager.layers) { layer in
                    AudioLayerRow(
                        layer: layer,
                        onToggle: { layerManager.toggleLayer(layer) },
                        onVolumeChange: { volume in
                            layerManager.setLayerVolume(layer.id, volume: volume)
                        },
                        onDelete: { layerManager.removeLayer(layer) }
                    )
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    showingAddLayer = true
                }) {
                    Label("Add Layer", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    showingPresetSelector = true
                }) {
                    Label("Presets", systemImage: "square.stack.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingAddLayer) {
            AddLayerSheet(layerManager: layerManager, isPresented: $showingAddLayer)
        }
        .sheet(isPresented: $showingPresetSelector) {
            LayerPresetSelector(layerManager: layerManager, isPresented: $showingPresetSelector)
        }
    }
}

// MARK: - Audio Layer Row

struct AudioLayerRow: View {
    let layer: AudioLayer
    let onToggle: () -> Void
    let onVolumeChange: (Float) -> Void
    let onDelete: () -> Void

    @State private var localVolume: Float

    init(layer: AudioLayer, onToggle: @escaping () -> Void, onVolumeChange: @escaping (Float) -> Void, onDelete: @escaping () -> Void) {
        self.layer = layer
        self.onToggle = onToggle
        self.onVolumeChange = onVolumeChange
        self.onDelete = onDelete
        _localVolume = State(initialValue: layer.volume)
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                // Enable/Disable Toggle
                Button(action: onToggle) {
                    Image(systemName: layer.isEnabled ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(layer.isEnabled ? .green : .secondary)
                }

                // Layer Icon and Name
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: layer.layerType.icon)
                            .foregroundColor(layer.isEnabled ? .blue : .secondary)
                        Text(layer.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(layer.isEnabled ? .primary : .secondary)
                    }

                    Text(layerDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Volume Percentage
                Text("\(Int(localVolume * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)

                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }

            // Volume Slider
            Slider(value: $localVolume, in: 0...1)
                .accentColor(layer.isEnabled ? .blue : .gray)
                .disabled(!layer.isEnabled)
                .onChange(of: localVolume) { newValue in
                    onVolumeChange(newValue)
                }
        }
        .padding()
        .background(layer.isEnabled ? Color(.systemGray6) : Color(.systemGray5))
        .cornerRadius(10)
        .opacity(layer.isEnabled ? 1.0 : 0.6)
    }

    private var layerDescription: String {
        switch layer.layerType {
        case .binauralBeat:
            if let beatFreq = layer.beatFrequency {
                return "\(String(format: "%.1f", beatFreq)) Hz binaural"
            }
            return "Binaural beat"
        case .tone:
            if let freq = layer.frequency {
                return "\(String(format: "%.1f", freq)) Hz tone"
            }
            return "Tone"
        case .ambient:
            return layer.ambientType?.rawValue ?? "Ambient sound"
        }
    }
}

// MARK: - Add Layer Sheet

struct AddLayerSheet: View {
    @ObservedObject var layerManager: MultiLayerAudioManager
    @Binding var isPresented: Bool

    @State private var selectedType: AudioLayerType = .binauralBeat
    @State private var layerName = ""

    // Binaural beat parameters
    @State private var baseFrequency: Double = 200
    @State private var beatFrequency: Double = 10
    @State private var binauralWaveform: AppConstants.WaveformType = .sine

    // Tone parameters
    @State private var toneFrequency: Double = 440
    @State private var toneWaveform: AppConstants.WaveformType = .sine

    // Ambient parameters
    @State private var ambientType: AmbientSoundType = .whiteNoise

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Layer Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(AudioLayerType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Layer Name", text: $layerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Parameters")) {
                    switch selectedType {
                    case .binauralBeat:
                        binauralBeatParameters
                    case .tone:
                        toneParameters
                    case .ambient:
                        ambientParameters
                    }
                }
            }
            .navigationTitle("Add Audio Layer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addLayer()
                    }
                    .disabled(layerName.isEmpty)
                }
            }
        }
    }

    private var binauralBeatParameters: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                Text("Base Frequency: \(String(format: "%.1f Hz", baseFrequency))")
                Slider(value: $baseFrequency, in: 100...500, step: 10)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Beat Frequency: \(String(format: "%.1f Hz", beatFrequency))")
                Slider(value: $beatFrequency, in: 0.5...40, step: 0.5)
            }

            Picker("Waveform", selection: $binauralWaveform) {
                ForEach(AppConstants.WaveformType.allCases, id: \.self) { waveform in
                    Text(waveform.rawValue).tag(waveform)
                }
            }
        }
    }

    private var toneParameters: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                Text("Frequency: \(String(format: "%.1f Hz", toneFrequency))")
                Slider(value: $toneFrequency, in: 100...1000, step: 10)
            }

            Picker("Waveform", selection: $toneWaveform) {
                ForEach(AppConstants.WaveformType.allCases, id: \.self) { waveform in
                    Text(waveform.rawValue).tag(waveform)
                }
            }
        }
    }

    private var ambientParameters: some View {
        Picker("Sound Type", selection: $ambientType) {
            ForEach(AmbientSoundType.allCases, id: \.self) { type in
                Label(type.rawValue, systemImage: type.icon).tag(type)
            }
        }
    }

    private func addLayer() {
        let layer: AudioLayer

        switch selectedType {
        case .binauralBeat:
            layer = .binauralBeat(
                name: layerName,
                baseFrequency: baseFrequency,
                beatFrequency: beatFrequency,
                waveformType: binauralWaveform
            )
        case .tone:
            layer = .tone(
                name: layerName,
                frequency: toneFrequency,
                waveformType: toneWaveform
            )
        case .ambient:
            layer = .ambient(
                name: layerName,
                ambientType: ambientType
            )
        }

        layerManager.addLayer(layer)
        isPresented = false
    }
}

// MARK: - Layer Preset Selector

struct LayerPresetSelector: View {
    @ObservedObject var layerManager: MultiLayerAudioManager
    @Binding var isPresented: Bool

    private let presets: [(name: String, description: String, icon: String, layers: () -> [AudioLayer])] = [
        (
            "Deep Meditation",
            "Theta waves with ocean background",
            "brain.head.profile",
            MultiLayerAudioManager.deepMeditationPreset
        ),
        (
            "Focus & Concentration",
            "Beta waves with white noise",
            "target",
            MultiLayerAudioManager.focusPreset
        ),
        (
            "Deep Sleep",
            "Delta waves with rain and brown noise",
            "moon.stars.fill",
            MultiLayerAudioManager.sleepPreset
        )
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(presets, id: \.name) { preset in
                    Button(action: {
                        loadPreset(preset.layers())
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: preset.icon)
                                .font(.title2)
                                .foregroundColor(.blue)
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
            .navigationTitle("Layer Presets")
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

    private func loadPreset(_ layers: [AudioLayer]) {
        // Clear existing layers
        layerManager.layers.removeAll()

        // Add new layers
        for layer in layers {
            layerManager.addLayer(layer)
        }

        isPresented = false
    }
}

// MARK: - Preview

#Preview {
    AudioLayerControl(layerManager: MultiLayerAudioManager())
        .padding()
}
