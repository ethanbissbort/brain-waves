//
//  IsochronicTonePreset.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation

struct IsochronicTonePreset: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var carrierFrequency: Double // Carrier frequency (100-500 Hz)
    var pulseFrequency: Double // Pulse/modulation frequency (0.5-100 Hz)
    var duration: TimeInterval // Duration in seconds
    var waveformType: AppConstants.WaveformType // Waveform type
    var rampConfig: FrequencyRampConfig? // Optional frequency ramping

    init(id: UUID = UUID(),
         name: String,
         carrierFrequency: Double,
         pulseFrequency: Double,
         duration: TimeInterval,
         waveformType: AppConstants.WaveformType = .sine,
         rampConfig: FrequencyRampConfig? = nil) {
        self.id = id
        self.name = name
        self.carrierFrequency = carrierFrequency
        self.pulseFrequency = pulseFrequency
        self.duration = duration
        self.waveformType = waveformType
        self.rampConfig = rampConfig
    }

    // Predefined therapeutic presets
    static let deepRelaxation = IsochronicTonePreset(
        name: "Deep Relaxation (Delta)",
        carrierFrequency: 250,
        pulseFrequency: 3,
        duration: 1800 // 30 minutes
    )

    static let creativeFlow = IsochronicTonePreset(
        name: "Creative Flow (Theta)",
        carrierFrequency: 250,
        pulseFrequency: 5,
        duration: 900 // 15 minutes
    )

    static let calmness = IsochronicTonePreset(
        name: "Calmness (Alpha)",
        carrierFrequency: 250,
        pulseFrequency: 10,
        duration: 600 // 10 minutes
    )

    static let concentration = IsochronicTonePreset(
        name: "Concentration (Beta)",
        carrierFrequency: 250,
        pulseFrequency: 18,
        duration: 1800 // 30 minutes
    )

    static let highFocus = IsochronicTonePreset(
        name: "High Focus (Gamma)",
        carrierFrequency: 250,
        pulseFrequency: 35,
        duration: 600 // 10 minutes
    )

    static var defaultPresets: [IsochronicTonePreset] {
        [deepRelaxation, creativeFlow, calmness, concentration, highFocus]
    }
}
