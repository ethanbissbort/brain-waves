//
//  BinauralBeatsViewModel.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class BinauralBeatsViewModel: BaseGeneratorViewModel {
    @Published var baseFrequency: Double = AppConstants.Audio.Frequency.defaultBase
    @Published var beatFrequency: Double = AppConstants.Audio.Frequency.defaultBeat
    @Published var volume: Float
    @Published var waveformType: AppConstants.WaveformType = .sine
    @Published var rampConfig: FrequencyRampConfig = FrequencyRampConfig()
    @Published var category: AppConstants.PresetCategory = .custom
    @Published var tags: [String] = []

    private let generator = BinauralBeatsGenerator()
    private let settingsManager = SettingsManager.shared

    // Frequency constraints
    let baseFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.baseMin...AppConstants.Audio.Frequency.baseMax
    let beatFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.beatMin...AppConstants.Audio.Frequency.beatMax

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
            baseFrequency: baseFrequency,
            beatFrequency: beatFrequency,
            duration: duration
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

        let preset = BinauralBeatPreset(
            name: presetName,
            baseFrequency: baseFrequency,
            beatFrequency: beatFrequency,
            duration: duration,
            waveformType: waveformType,
            rampConfig: rampConfig.enabled ? rampConfig : nil,
            category: category,
            tags: tags
        )

        presetStore.addBinauralPreset(preset)
        presetName = ""
        showingSavePreset = false
    }

    func loadPreset(_ preset: BinauralBeatPreset) {
        baseFrequency = preset.baseFrequency
        beatFrequency = preset.beatFrequency
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
        AppConstants.BrainwaveType.type(for: beatFrequency).rawValue
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        generator.setVolume(volume)
        // Save to settings manager
        settingsManager.volume = volume
    }
}
