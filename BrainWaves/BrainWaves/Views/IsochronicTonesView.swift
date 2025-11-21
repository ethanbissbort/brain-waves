//
//  IsochronicTonesView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct IsochronicTonesView: View {
    @StateObject private var viewModel = IsochronicTonesViewModel()
    @EnvironmentObject var presetCoordinator: PresetCoordinator

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Brainwave type indicator
                    Text(viewModel.getBrainwaveType())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .padding()

                    // Carrier Frequency Control
                    FrequencyControl(
                        label: "Carrier Frequency",
                        frequency: $viewModel.carrierFrequency,
                        range: viewModel.carrierFrequencyRange,
                        unit: "Hz"
                    )
                    .disabled(viewModel.isPlaying)

                    // Pulse Frequency Control
                    FrequencyControl(
                        label: "Pulse Frequency",
                        frequency: $viewModel.pulseFrequency,
                        range: viewModel.pulseFrequencyRange,
                        unit: "Hz"
                    )
                    .disabled(viewModel.isPlaying)

                    // Waveform Selection
                    WaveformSelector(selectedWaveform: $viewModel.waveformType)
                        .disabled(viewModel.isPlaying)

                    // Volume Control
                    VolumeControl(
                        volume: $viewModel.volume,
                        onVolumeChange: viewModel.setVolume
                    )

                    // Frequency explanation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How it works:")
                            .font(.headline)
                        Text("Tone frequency: \(String(format: "%.1f Hz", viewModel.carrierFrequency))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Pulsing at: \(String(format: "%.1f Hz", viewModel.pulseFrequency))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Creates rhythmic on/off pattern")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        Text("No stereo headphones required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Timer Control
                    TimerControl(
                        duration: $viewModel.duration,
                        durationPresets: viewModel.durationPresets,
                        currentTime: viewModel.currentTime,
                        isPlaying: viewModel.isPlaying
                    )

                    // Playback Controls
                    PlaybackControls(
                        isPlaying: viewModel.isPlaying,
                        onPlay: viewModel.play,
                        onPause: viewModel.pause,
                        onStop: viewModel.stop
                    )

                    // Save Preset Button
                    Button(action: {
                        viewModel.showingSavePreset = true
                    }) {
                        Label("Save as Preset", systemImage: "bookmark.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.isPlaying)

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Isochronic Tones")
            .sheet(isPresented: $viewModel.showingSavePreset) {
                SaveIsochronicPresetSheet(
                    presetName: $viewModel.presetName,
                    isPresented: $viewModel.showingSavePreset,
                    onSave: viewModel.savePreset
                )
            }
            .onAppear {
                loadPresetIfSelected()
            }
            .onChange(of: presetCoordinator.selectedIsochronicPreset) { _ in
                loadPresetIfSelected()
            }
        }
    }

    private func loadPresetIfSelected() {
        if let preset = presetCoordinator.selectedIsochronicPreset {
            viewModel.loadPreset(preset)
            presetCoordinator.clearIsochronicPreset()
        }
    }
}

struct SaveIsochronicPresetSheet: View {
    @Binding var presetName: String
    @Binding var isPresented: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Save Current Settings")
                    .font(.headline)

                TextField("Preset Name", text: $presetName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Save") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .disabled(presetName.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presetName = ""
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct IsochronicTonesView_Previews: PreviewProvider {
    static var previews: some View {
        IsochronicTonesView()
    }
}
