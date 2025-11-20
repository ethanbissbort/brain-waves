//
//  PresetsView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct PresetsView: View {
    @ObservedObject var presetStore = PresetStore.shared
    @EnvironmentObject var presetCoordinator: PresetCoordinator
    @Binding var selectedTab: Int
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
                    BinauralPresetsListView(
                        presets: presetStore.binauralPresets,
                        selectedTab: $selectedTab
                    )
                } else {
                    IsochronicPresetsListView(
                        presets: presetStore.isochronicPresets,
                        selectedTab: $selectedTab
                    )
                }
            }
            .navigationTitle("Presets")
        }
    }
}

struct BinauralPresetsListView: View {
    let presets: [BinauralBeatPreset]
    @ObservedObject var presetStore = PresetStore.shared
    @EnvironmentObject var presetCoordinator: PresetCoordinator
    @Binding var selectedTab: Int

    var body: some View {
        List {
            ForEach(presets) { preset in
                Button(action: {
                    presetCoordinator.selectBinauralPreset(preset)
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
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct IsochronicPresetsListView: View {
    let presets: [IsochronicTonePreset]
    @ObservedObject var presetStore = PresetStore.shared
    @EnvironmentObject var presetCoordinator: PresetCoordinator
    @Binding var selectedTab: Int

    var body: some View {
        List {
            ForEach(presets) { preset in
                Button(action: {
                    presetCoordinator.selectIsochronicPreset(preset)
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
