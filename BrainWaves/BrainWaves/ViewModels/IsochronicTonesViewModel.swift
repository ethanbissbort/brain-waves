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
    @Published var volume: Float
    @Published var waveformType: AppConstants.WaveformType = .sine
    @Published var rampConfig: FrequencyRampConfig = FrequencyRampConfig()
    @Published var category: AppConstants.PresetCategory = .custom
    @Published var tags: [String] = []

    private let generator = IsochronicTonesGenerator()
    private let settingsManager = SettingsManager.shared

    // Frequency constraints
    let carrierFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.baseMin...AppConstants.Audio.Frequency.baseMax
    let pulseFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.beatMin...AppConstants.Audio.Frequency.beatMax

    override init() {
        // Load saved volume
        self.volume = settingsManager.volume

        super.init()

        // Subscribe to generator state
        generator.$isPlaying
            .assign(to: &$isPlaying)

        generator.$currentTime
            .assign(to: &$currentTime)

        generator.$duration
            .assign(to: &$duration)

        // Set initial volume on generator
        generator.setVolume(volume)

        // Subscribe waveformType to generator
        $waveformType
            .assign(to: \.waveformType, on: generator)
            .store(in: &cancellables)
    }

    func play() {
        generator.start(
            carrierFrequency: carrierFrequency,
            pulseFrequency: pulseFrequency,
            duration: duration,
            rampConfig: rampConfig.enabled ? rampConfig : nil
        )
        HapticManager.shared.playStart()
    }

    func pause() {
        generator.pause()
        HapticManager.shared.playButtonTap()
    }

    func stop() {
        generator.stop()
        HapticManager.shared.playStop()
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
            duration: duration,
            waveformType: waveformType,
            rampConfig: rampConfig.enabled ? rampConfig : nil,
            category: category,
            tags: tags
        )

        presetStore.addIsochronicPreset(preset)
        presetName = ""
        showingSavePreset = false
    }

    func loadPreset(_ preset: IsochronicTonePreset) {
        carrierFrequency = preset.carrierFrequency
        pulseFrequency = preset.pulseFrequency
        duration = preset.duration
        waveformType = preset.waveformType
        category = preset.category
        tags = preset.tags
        if let rampConfig = preset.rampConfig {
            self.rampConfig = rampConfig
        }
        HapticManager.shared.playPresetLoad()
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
        // Save to settings manager
        settingsManager.volume = volume
    }
}
