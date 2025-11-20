//
//  IsochronicTonesViewModel.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class IsochronicTonesViewModel: ObservableObject {
    @Published var carrierFrequency: Double = 250.0
    @Published var pulseFrequency: Double = 10.0
    @Published var duration: TimeInterval = 600.0 // 10 minutes default
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var showingSavePreset = false
    @Published var presetName = ""

    private let generator = IsochronicTonesGenerator()
    private let presetStore = PresetStore.shared
    private var cancellables = Set<AnyCancellable>()

    // Frequency constraints
    let carrierFrequencyRange: ClosedRange<Double> = 100...500
    let pulseFrequencyRange: ClosedRange<Double> = 0.5...100

    // Duration presets (in seconds)
    let durationPresets: [TimeInterval] = [300, 600, 900, 1800, 3600] // 5, 10, 15, 30, 60 minutes

    init() {
        // Subscribe to generator state
        generator.$isPlaying
            .assign(to: &$isPlaying)

        generator.$currentTime
            .assign(to: &$currentTime)
    }

    func play() {
        generator.start(
            carrierFrequency: carrierFrequency,
            pulseFrequency: pulseFrequency,
            duration: duration
        )
    }

    func pause() {
        generator.pause()
    }

    func stop() {
        generator.stop()
    }

    func resume() {
        generator.resume()
    }

    func setDuration(_ duration: TimeInterval) {
        self.duration = duration
    }

    func savePreset() {
        guard !presetName.isEmpty else { return }

        let preset = IsochronicTonePreset(
            name: presetName,
            carrierFrequency: carrierFrequency,
            pulseFrequency: pulseFrequency,
            duration: duration
        )

        presetStore.addIsochronicPreset(preset)
        presetName = ""
        showingSavePreset = false
    }

    func loadPreset(_ preset: IsochronicTonePreset) {
        carrierFrequency = preset.carrierFrequency
        pulseFrequency = preset.pulseFrequency
        duration = preset.duration
    }

    var remainingTime: TimeInterval {
        max(0, duration - currentTime)
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(currentTime / duration, 1.0)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func getBrainwaveType() -> String {
        switch pulseFrequency {
        case 0..<4:
            return "Delta - Deep Relaxation"
        case 4..<8:
            return "Theta - Creative Flow"
        case 8..<14:
            return "Alpha - Calmness"
        case 14..<30:
            return "Beta - Concentration"
        case 30...100:
            return "Gamma - High Focus"
        default:
            return "Custom"
        }
    }
}
