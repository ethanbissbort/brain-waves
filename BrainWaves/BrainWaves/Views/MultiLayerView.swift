//
//  MultiLayerView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct MultiLayerView: View {
    @StateObject private var layerManager = MultiLayerAudioManager()
    @StateObject private var effectsManager = AudioEffectsManager()
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 600 // 10 minutes default
    @State private var timer: Timer?
    @State private var showingSavePreset = false
    @State private var presetName = ""

    private let durationPresets: [TimeInterval] = [300, 600, 900, 1800, 3600] // 5m, 10m, 15m, 30m, 60m

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                    // Info Banner
                    VStack(spacing: 8) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)

                        Text("Multi-Layer Audio")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Create complex soundscapes by layering multiple audio sources")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)

                    // Audio Layers Control
                    AudioLayerControl(layerManager: layerManager)

                    // Audio Effects Control
                    AudioEffectsControl(effectsManager: effectsManager)

                    // Timer Display
                    if layerManager.isPlaying {
                        EnhancedTimerDisplay(
                            currentTime: currentTime,
                            duration: duration,
                            isPlaying: layerManager.isPlaying
                        )
                    } else {
                        TimerControl(
                            duration: $duration,
                            durationPresets: durationPresets,
                            currentTime: currentTime,
                            isPlaying: layerManager.isPlaying
                        )
                    }

                    // Playback Controls
                    HStack(spacing: 20) {
                        if !layerManager.isPlaying {
                            Button(action: play) {
                                Label("Play", systemImage: "play.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(layerManager.layers.isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(layerManager.layers.isEmpty)
                        } else {
                            Button(action: pause) {
                                Label("Pause", systemImage: "pause.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            Button(action: stop) {
                                Label("Stop", systemImage: "stop.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Save Configuration Button
                    if !layerManager.layers.isEmpty {
                        Button(action: {
                            showingSavePreset = true
                        }) {
                            Label("Save Layer Configuration", systemImage: "square.and.arrow.down.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(layerManager.isPlaying)
                    }

                    // Tips Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Tips for Multi-Layer Audio")
                                .font(.headline)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(icon: "checkmark.circle.fill", text: "Start with a binaural beat layer for the core frequency")
                            TipRow(icon: "checkmark.circle.fill", text: "Add ambient sounds at lower volumes (20-40%)")
                            TipRow(icon: "checkmark.circle.fill", text: "Use the master volume to control overall output")
                            TipRow(icon: "checkmark.circle.fill", text: "Disable layers to A/B test different combinations")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
                .volumePinchGesture(
                    volume: Binding(
                        get: { layerManager.masterVolume },
                        set: { layerManager.setMasterVolume($0) }
                    ),
                    onVolumeChange: { layerManager.setMasterVolume($0) },
                    isEnabled: true
                )
                .doubleTapFavorite {
                    showingSavePreset = true
                }

                // Gesture Feedback Overlay
                GestureFeedbackView()
            }
            .navigationTitle("Multi-Layer")
            .sheet(isPresented: $showingSavePreset) {
                SaveMultiLayerConfigSheet(
                    presetName: $presetName,
                    isPresented: $showingSavePreset,
                    onSave: saveConfiguration
                )
            }
        }
    }

    // MARK: - Playback Control

    private func play() {
        HapticManager.shared.playImpact()
        layerManager.play()
        currentTime = 0
        startTimer()
    }

    private func pause() {
        HapticManager.shared.playSelection()
        layerManager.pause()
        stopTimer()
    }

    private func stop() {
        HapticManager.shared.playImpact()
        layerManager.stop()
        currentTime = 0
        stopTimer()
    }

    // MARK: - Timer Management

    private func startTimer() {
        stopTimer() // Clean up any existing timer

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentTime += 0.1

            // Check milestone notifications
            TimerMilestoneManager.shared.checkMilestone(
                remainingTime: duration - currentTime,
                isPlaying: layerManager.isPlaying
            )

            // Stop when duration is reached
            if currentTime >= duration {
                stop()
                TimerMilestoneManager.shared.notifyCompletion(sessionType: "Multi-Layer")
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Save Configuration

    private func saveConfiguration() {
        // This would save the current layer configuration
        // In a real implementation, this would persist to UserDefaults or a database
        Logger.shared.info("Saving multi-layer configuration: \(presetName)")
        Logger.shared.info("Layers: \(layerManager.layers.count)")

        // Clear the preset name
        presetName = ""
        showingSavePreset = false

        // Show success haptic
        HapticManager.shared.playSuccess()
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Save Multi-Layer Config Sheet

struct SaveMultiLayerConfigSheet: View {
    @Binding var presetName: String
    @Binding var isPresented: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Save Layer Configuration")
                    .font(.headline)

                Text("This will save your current layer setup including all frequencies, waveforms, and volume levels")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                TextField("Configuration Name", text: $presetName)
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
            .navigationTitle("Save Configuration")
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

// MARK: - Preview

#Preview {
    MultiLayerView()
        .environmentObject(PresetCoordinator())
}
