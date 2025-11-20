//
//  PresetsView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct PresetsView: View {
    @ObservedObject var presetStore = PresetStore.shared
    @State private var selectedSegment = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Preset Type", selection: $selectedSegment) {
                    Text("Binaural Beats").tag(0)
                    Text("Isochronic Tones").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedSegment == 0 {
                    BinauralPresetsListView(presets: presetStore.binauralPresets)
                } else {
                    IsochronicPresetsListView(presets: presetStore.isochronicPresets)
                }
            }
            .navigationTitle("Presets")
        }
    }
}

struct BinauralPresetsListView: View {
    let presets: [BinauralBeatPreset]
    @ObservedObject var presetStore = PresetStore.shared
    @State private var selectedPreset: BinauralBeatPreset?
    @State private var showingLoadConfirmation = false

    var body: some View {
        List {
            ForEach(presets) { preset in
                Button(action: {
                    selectedPreset = preset
                    showingLoadConfirmation = true
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preset.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack {
                            Text("Base: \(String(format: "%.1f Hz", preset.baseFrequency))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text("Beat: \(String(format: "%.1f Hz", preset.beatFrequency))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text("\(formatDuration(preset.duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        presetStore.deleteBinauralPreset(preset)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .alert("Load Preset", isPresented: $showingLoadConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Load") {
                // This would need to communicate with the BinauralBeatsView
                // For now, we'll just dismiss
            }
        } message: {
            if let preset = selectedPreset {
                Text("Go to Binaural Beats tab and load '\(preset.name)'?")
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct IsochronicPresetsListView: View {
    let presets: [IsochronicTonePreset]
    @ObservedObject var presetStore = PresetStore.shared
    @State private var selectedPreset: IsochronicTonePreset?
    @State private var showingLoadConfirmation = false

    var body: some View {
        List {
            ForEach(presets) { preset in
                Button(action: {
                    selectedPreset = preset
                    showingLoadConfirmation = true
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preset.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack {
                            Text("Carrier: \(String(format: "%.1f Hz", preset.carrierFrequency))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text("Pulse: \(String(format: "%.1f Hz", preset.pulseFrequency))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text("\(formatDuration(preset.duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        presetStore.deleteIsochronicPreset(preset)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .alert("Load Preset", isPresented: $showingLoadConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Load") {
                // This would need to communicate with the IsochronicTonesView
                // For now, we'll just dismiss
            }
        } message: {
            if let preset = selectedPreset {
                Text("Go to Isochronic Tones tab and load '\(preset.name)'?")
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct PresetsView_Previews: PreviewProvider {
    static var previews: some View {
        PresetsView()
    }
}
