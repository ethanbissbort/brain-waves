//
//  MultiLayerPreset.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation

struct MultiLayerPreset: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var layers: [AudioLayer]
    var duration: TimeInterval
    var category: AppConstants.PresetCategory
    var tags: [String]

    init(id: UUID = UUID(),
         name: String,
         layers: [AudioLayer],
         duration: TimeInterval,
         category: AppConstants.PresetCategory = .custom,
         tags: [String] = []) {
        self.id = id
        self.name = name
        self.layers = layers
        self.duration = duration
        self.category = category
        self.tags = tags
    }

    // Predefined templates
    static let deepMeditation = MultiLayerPreset(
        name: "Deep Meditation",
        layers: [
            .binauralBeat(name: "Theta Base", baseFrequency: 200, beatFrequency: 6, volume: 0.6),
            .ambient(name: "Ocean Waves", ambientType: .ocean, volume: 0.3),
            .tone(name: "Background Tone", frequency: 432, waveformType: .sine, volume: 0.2)
        ],
        duration: 1200,
        category: .meditation,
        tags: ["theta", "ocean", "deep meditation"]
    )

    static let focusFlow = MultiLayerPreset(
        name: "Focus Flow",
        layers: [
            .binauralBeat(name: "Beta Focus", baseFrequency: 200, beatFrequency: 18, volume: 0.7),
            .ambient(name: "White Noise", ambientType: .whiteNoise, volume: 0.2)
        ],
        duration: 1800,
        category: .focus,
        tags: ["beta", "concentration", "productivity"]
    )

    static let deepSleep = MultiLayerPreset(
        name: "Deep Sleep",
        layers: [
            .binauralBeat(name: "Delta Sleep", baseFrequency: 200, beatFrequency: 2, volume: 0.5),
            .ambient(name: "Rain", ambientType: .rain, volume: 0.4),
            .ambient(name: "Brown Noise", ambientType: .brownNoise, volume: 0.2)
        ],
        duration: 2400,
        category: .sleep,
        tags: ["delta", "rain", "deep sleep"]
    )

    static var defaultPresets: [MultiLayerPreset] {
        [deepMeditation, focusFlow, deepSleep]
    }
}
