//
//  BinauralBeatPreset.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation

struct BinauralBeatPreset: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var baseFrequency: Double // Carrier frequency (100-500 Hz)
    var beatFrequency: Double // Difference frequency (0.5-100 Hz)
    var duration: TimeInterval // Duration in seconds
    var waveformType: AppConstants.WaveformType // Waveform type
    var rampConfig: FrequencyRampConfig? // Optional frequency ramping

    init(id: UUID = UUID(),
         name: String,
         baseFrequency: Double,
         beatFrequency: Double,
         duration: TimeInterval,
         waveformType: AppConstants.WaveformType = .sine,
         rampConfig: FrequencyRampConfig? = nil) {
        self.id = id
        self.name = name
        self.baseFrequency = baseFrequency
        self.beatFrequency = beatFrequency
        self.duration = duration
        self.waveformType = waveformType
        self.rampConfig = rampConfig
    }

    // Predefined therapeutic presets
    static let deepSleep = BinauralBeatPreset(
        name: "Deep Sleep (Delta)",
        baseFrequency: 200,
        beatFrequency: 2,
        duration: 1800 // 30 minutes
    )

    static let meditation = BinauralBeatPreset(
        name: "Meditation (Theta)",
        baseFrequency: 200,
        beatFrequency: 6,
        duration: 900 // 15 minutes
    )

    static let relaxation = BinauralBeatPreset(
        name: "Relaxation (Alpha)",
        baseFrequency: 200,
        beatFrequency: 10,
        duration: 600 // 10 minutes
    )

    static let focus = BinauralBeatPreset(
        name: "Focus (Beta)",
        baseFrequency: 200,
        beatFrequency: 20,
        duration: 1800 // 30 minutes
    )

    static let peakAwareness = BinauralBeatPreset(
        name: "Peak Awareness (Gamma)",
        baseFrequency: 200,
        beatFrequency: 40,
        duration: 600 // 10 minutes
    )

    static var defaultPresets: [BinauralBeatPreset] {
        [deepSleep, meditation, relaxation, focus, peakAwareness]
    }
}
