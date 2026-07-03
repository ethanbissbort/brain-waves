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
    var category: AppConstants.PresetCategory // Preset category
    var tags: [String] // Custom tags for filtering

    init(id: UUID = UUID(),
         name: String,
         baseFrequency: Double,
         beatFrequency: Double,
         duration: TimeInterval,
         waveformType: AppConstants.WaveformType = .sine,
         rampConfig: FrequencyRampConfig? = nil,
         category: AppConstants.PresetCategory = .custom,
         tags: [String] = []) {
        self.id = id
        self.name = name
        self.baseFrequency = baseFrequency
        self.beatFrequency = beatFrequency
        self.duration = duration
        self.waveformType = waveformType
        self.rampConfig = rampConfig
        self.category = category
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case id, name, baseFrequency, beatFrequency, duration, waveformType, rampConfig, category, tags
    }

    // Custom decoding tolerates legacy data persisted before the waveformType/rampConfig/category/tags
    // fields were introduced (Phase 2). Missing keys fall back to the same defaults as the memberwise
    // init, so pre-Phase-2 presets decode instead of silently failing (and being dropped by `try?`).
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        baseFrequency = try container.decode(Double.self, forKey: .baseFrequency)
        beatFrequency = try container.decode(Double.self, forKey: .beatFrequency)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        waveformType = try container.decodeIfPresent(AppConstants.WaveformType.self, forKey: .waveformType) ?? .sine
        rampConfig = try container.decodeIfPresent(FrequencyRampConfig.self, forKey: .rampConfig)
        category = try container.decodeIfPresent(AppConstants.PresetCategory.self, forKey: .category) ?? .custom
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    // Predefined therapeutic presets
    static let deepSleep = BinauralBeatPreset(
        name: "Deep Sleep (Delta)",
        baseFrequency: 200,
        beatFrequency: 2,
        duration: 1800, // 30 minutes
        category: .sleep,
        tags: ["delta", "deep sleep", "rest"]
    )

    static let meditation = BinauralBeatPreset(
        name: "Meditation (Theta)",
        baseFrequency: 200,
        beatFrequency: 6,
        duration: 900, // 15 minutes
        category: .meditation,
        tags: ["theta", "mindfulness", "calm"]
    )

    static let relaxation = BinauralBeatPreset(
        name: "Relaxation (Alpha)",
        baseFrequency: 200,
        beatFrequency: 10,
        duration: 600, // 10 minutes
        category: .relaxation,
        tags: ["alpha", "stress relief", "calm"]
    )

    static let focus = BinauralBeatPreset(
        name: "Focus (Beta)",
        baseFrequency: 200,
        beatFrequency: 20,
        duration: 1800, // 30 minutes
        category: .focus,
        tags: ["beta", "productivity", "concentration"]
    )

    static let peakAwareness = BinauralBeatPreset(
        name: "Peak Awareness (Gamma)",
        baseFrequency: 200,
        beatFrequency: 40,
        duration: 600, // 10 minutes
        category: .focus,
        tags: ["gamma", "peak performance", "awareness"]
    )

    static var defaultPresets: [BinauralBeatPreset] {
        [deepSleep, meditation, relaxation, focus, peakAwareness]
    }
}
