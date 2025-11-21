//
//  BinauralBeatsView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct BinauralBeatsView: View {
    @StateObject private var viewModel = BinauralBeatsViewModel()
    @EnvironmentObject var presetCoordinator: PresetCoordinator

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Brainwave type indicator
                    Text(viewModel.getBrainwaveType())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding()

                    // Base Frequency Control
                    FrequencyControl(
                        label: "Base Frequency (Carrier)",
                        frequency: $viewModel.baseFrequency,
                        range: viewModel.baseFrequencyRange,
                        unit: "Hz"
                    )
                    .disabled(viewModel.isPlaying)

                    // Beat Frequency Control
                    FrequencyControl(
                        label: "Beat Frequency (Difference)",
                        frequency: $viewModel.beatFrequency,
                        range: viewModel.beatFrequencyRange,
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
                        Text("Left ear: \(String(format: "%.1f Hz", viewModel.baseFrequency))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Right ear: \(String(format: "%.1f Hz", viewModel.baseFrequency + viewModel.beatFrequency))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Your brain perceives: \(String(format: "%.1f Hz", viewModel.beatFrequency))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
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
            .navigationTitle("Binaural Beats")
            .sheet(isPresented: $viewModel.showingSavePreset) {
                SavePresetSheet(
                    presetName: $viewModel.presetName,
                    isPresented: $viewModel.showingSavePreset,
                    onSave: viewModel.savePreset
                )
            }
            .onAppear {
                loadPresetIfSelected()
            }
            .onChange(of: presetCoordinator.selectedBinauralPreset) { _ in
                loadPresetIfSelected()
            }
        }
    }

    private func loadPresetIfSelected() {
        if let preset = presetCoordinator.selectedBinauralPreset {
            viewModel.loadPreset(preset)
            presetCoordinator.clearBinauralPreset()
        }
    }
}

struct SavePresetSheet: View {
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

struct BinauralBeatsView_Previews: PreviewProvider {
    static var previews: some View {
        BinauralBeatsView()
    }
}
