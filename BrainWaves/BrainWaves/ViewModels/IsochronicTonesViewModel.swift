//
//  IsochronicTonesViewModel.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class IsochronicTonesViewModel: BaseGeneratorViewModel {
    @Published var carrierFrequency: Double = AppConstants.Audio.Frequency.defaultCarrier
    @Published var pulseFrequency: Double = AppConstants.Audio.Frequency.defaultBeat
    @Published var volume: Float = AppConstants.Audio.defaultVolume

    private let generator = IsochronicTonesGenerator()

    // Frequency constraints
    let carrierFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.baseMin...AppConstants.Audio.Frequency.baseMax
    let pulseFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.beatMin...AppConstants.Audio.Frequency.beatMax

    override init() {
        super.init()

        // Subscribe to generator state
        generator.$isPlaying
            .assign(to: &$isPlaying)

        generator.$currentTime
            .assign(to: &$currentTime)

        generator.$duration
            .assign(to: &$duration)
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

    func getBrainwaveType() -> String {
        // Custom descriptions for isochronic tones
        let baseType = AppConstants.BrainwaveType.type(for: pulseFrequency)
        switch baseType {
        case .delta:
            return "Delta - Deep Relaxation"
        case .theta:
            return "Theta - Creative Flow"
        case .alpha:
            return "Alpha - Calmness"
        case .beta:
            return "Beta - Concentration"
        case .gamma:
            return "Gamma - High Focus"
        case .custom:
            return "Custom"
        }
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        generator.setVolume(volume)
    }
}
