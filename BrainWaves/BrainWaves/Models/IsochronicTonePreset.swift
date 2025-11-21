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
    var category: AppConstants.PresetCategory // Preset category
    var tags: [String] // Custom tags for filtering

    init(id: UUID = UUID(),
         name: String,
         carrierFrequency: Double,
         pulseFrequency: Double,
         duration: TimeInterval,
         waveformType: AppConstants.WaveformType = .sine,
         rampConfig: FrequencyRampConfig? = nil,
         category: AppConstants.PresetCategory = .custom,
         tags: [String] = []) {
        self.id = id
        self.name = name
        self.carrierFrequency = carrierFrequency
        self.pulseFrequency = pulseFrequency
        self.duration = duration
        self.waveformType = waveformType
        self.rampConfig = rampConfig
        self.category = category
        self.tags = tags
    }

    // Predefined therapeutic presets
    static let deepRelaxation = IsochronicTonePreset(
        name: "Deep Relaxation (Delta)",
        carrierFrequency: 250,
        pulseFrequency: 3,
        duration: 1800, // 30 minutes
        category: .relaxation,
        tags: ["delta", "deep relaxation", "stress relief"]
    )

    static let creativeFlow = IsochronicTonePreset(
        name: "Creative Flow (Theta)",
        carrierFrequency: 250,
        pulseFrequency: 5,
        duration: 900, // 15 minutes
        category: .creativity,
        tags: ["theta", "creativity", "inspiration"]
    )

    static let calmness = IsochronicTonePreset(
        name: "Calmness (Alpha)",
        carrierFrequency: 250,
        pulseFrequency: 10,
        duration: 600, // 10 minutes
        category: .relaxation,
        tags: ["alpha", "calm", "peace"]
    )

    static let concentration = IsochronicTonePreset(
        name: "Concentration (Beta)",
        carrierFrequency: 250,
        pulseFrequency: 18,
        duration: 1800, // 30 minutes
        category: .study,
        tags: ["beta", "concentration", "learning"]
    )

    static let highFocus = IsochronicTonePreset(
        name: "High Focus (Gamma)",
        carrierFrequency: 250,
        pulseFrequency: 35,
        duration: 600, // 10 minutes
        category: .focus,
        tags: ["gamma", "high focus", "performance"]
    )

    static var defaultPresets: [IsochronicTonePreset] {
        [deepRelaxation, creativeFlow, calmness, concentration, highFocus]
    }
}
