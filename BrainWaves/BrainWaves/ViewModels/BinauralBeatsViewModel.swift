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
    @Published var volume: Float = AppConstants.Audio.defaultVolume

    private let generator = BinauralBeatsGenerator()

    // Frequency constraints
    let baseFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.baseMin...AppConstants.Audio.Frequency.baseMax
    let beatFrequencyRange: ClosedRange<Double> = AppConstants.Audio.Frequency.beatMin...AppConstants.Audio.Frequency.beatMax

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
            baseFrequency: baseFrequency,
            beatFrequency: beatFrequency,
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

        let preset = BinauralBeatPreset(
            name: presetName,
            baseFrequency: baseFrequency,
            beatFrequency: beatFrequency,
            duration: duration
        )

        presetStore.addBinauralPreset(preset)
        presetName = ""
        showingSavePreset = false
    }

    func loadPreset(_ preset: BinauralBeatPreset) {
        baseFrequency = preset.baseFrequency
        beatFrequency = preset.beatFrequency
        duration = preset.duration
    }

    func getBrainwaveType() -> String {
        AppConstants.BrainwaveType.type(for: beatFrequency).rawValue
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        generator.setVolume(volume)
    }
}
