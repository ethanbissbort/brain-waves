//
//  AudioEffectsManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import AVFoundation

// MARK: - Audio Effect Types

enum AudioEffectType: String, CaseIterable, Codable {
    case reverb = "Reverb"
    case delay = "Delay"
    case lowPassFilter = "Low-Pass Filter"
    case highPassFilter = "High-Pass Filter"
    case bandPassFilter = "Band-Pass Filter"
    case distortion = "Distortion"
    case eq = "EQ"

    var icon: String {
        switch self {
        case .reverb:
            return "waveform.circle.fill"
        case .delay:
            return "arrow.triangle.2.circlepath"
        case .lowPassFilter:
            return "arrow.down.to.line"
        case .highPassFilter:
            return "arrow.up.to.line"
        case .bandPassFilter:
            return "arrow.left.and.right"
        case .distortion:
            return "waveform.path.badge.plus"
        case .eq:
            return "slider.horizontal.3"
        }
    }

    var description: String {
        switch self {
        case .reverb:
            return "Adds spatial depth and ambience"
        case .delay:
            return "Creates echo effects"
        case .lowPassFilter:
            return "Removes high frequencies"
        case .highPassFilter:
            return "Removes low frequencies"
        case .bandPassFilter:
            return "Isolates a frequency range"
        case .distortion:
            return "Adds harmonic richness"
        case .eq:
            return "Adjust frequency balance"
        }
    }
}

// MARK: - Audio Effect Configuration

struct AudioEffectConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var effectType: AudioEffectType
    var isEnabled: Bool
    var parameters: EffectParameters

    init(
        id: UUID = UUID(),
        effectType: AudioEffectType,
        isEnabled: Bool = false,
        parameters: EffectParameters = EffectParameters()
    ) {
        self.id = id
        self.effectType = effectType
        self.isEnabled = isEnabled
        self.parameters = parameters
    }

    struct EffectParameters: Codable, Equatable {
        // Reverb parameters
        var reverbMix: Float = 0.3
        var reverbSize: Float = 0.5

        // Delay parameters
        var delayTime: Float = 0.5 // seconds
        var delayMix: Float = 0.3
        var delayFeedback: Float = 0.3

        // Filter parameters
        var cutoffFrequency: Float = 1000 // Hz
        var resonance: Float = 0.0

        // Band-pass parameters
        var bandwidth: Float = 600 // Hz

        // Distortion parameters
        var distortionMix: Float = 0.3
        var distortionAmount: Float = 0.5

        // EQ parameters
        var eqLowGain: Float = 0 // dB
        var eqMidGain: Float = 0 // dB
        var eqHighGain: Float = 0 // dB
    }
}

// MARK: - Audio Effects Manager

class AudioEffectsManager: ObservableObject {
    @Published var effects: [AudioEffectConfig] = []

    private var reverbNode: AVAudioUnitReverb?
    private var delayNode: AVAudioUnitDelay?
    private var lowPassNode: AVAudioUnitEQ?
    private var highPassNode: AVAudioUnitEQ?
    private var bandPassNode: AVAudioUnitEQ?
    private var distortionNode: AVAudioUnitDistortion?
    private var eqNode: AVAudioUnitEQ?

    init() {
        setupDefaultEffects()
    }

    // MARK: - Setup

    private func setupDefaultEffects() {
        effects = [
            AudioEffectConfig(effectType: .reverb),
            AudioEffectConfig(effectType: .delay),
            AudioEffectConfig(effectType: .lowPassFilter),
            AudioEffectConfig(effectType: .highPassFilter),
            AudioEffectConfig(effectType: .distortion),
            AudioEffectConfig(effectType: .eq)
        ]
    }

    // MARK: - Effect Management

    func toggleEffect(_ effectId: UUID) {
        if let index = effects.firstIndex(where: { $0.id == effectId }) {
            effects[index].isEnabled.toggle()
        }
    }

    func updateEffect(_ effect: AudioEffectConfig) {
        if let index = effects.firstIndex(where: { $0.id == effect.id }) {
            effects[index] = effect
        }
    }

    func updateEffectParameters(_ effectId: UUID, parameters: AudioEffectConfig.EffectParameters) {
        if let index = effects.firstIndex(where: { $0.id == effectId }) {
            effects[index].parameters = parameters
        }
    }

    // MARK: - Audio Unit Creation

    func createEffectUnits(for engine: AVAudioEngine) -> [AVAudioUnit] {
        var units: [AVAudioUnit] = []

        for effect in effects where effect.isEnabled {
            switch effect.effectType {
            case .reverb:
                if let unit = createReverbUnit(with: effect.parameters) {
                    units.append(unit)
                }
            case .delay:
                if let unit = createDelayUnit(with: effect.parameters) {
                    units.append(unit)
                }
            case .lowPassFilter:
                if let unit = createLowPassUnit(with: effect.parameters) {
                    units.append(unit)
                }
            case .highPassFilter:
                if let unit = createHighPassUnit(with: effect.parameters) {
                    units.append(unit)
                }
            case .bandPassFilter:
                if let unit = createBandPassUnit(with: effect.parameters) {
                    units.append(unit)
                }
            case .distortion:
                if let unit = createDistortionUnit(with: effect.parameters) {
                    units.append(unit)
                }
            case .eq:
                if let unit = createEQUnit(with: effect.parameters) {
                    units.append(unit)
                }
            }
        }

        return units
    }

    // MARK: - Effect Unit Creators

    private func createReverbUnit(with params: AudioEffectConfig.EffectParameters) -> AVAudioUnit? {
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.mediumHall)
        reverb.wetDryMix = params.reverbMix * 100 // 0-100

        reverbNode = reverb
        return reverb
    }

    private func createDelayUnit(with params: AudioEffectConfig.EffectParameters) -> AVAudioUnit? {
        let delay = AVAudioUnitDelay()
        delay.delayTime = TimeInterval(params.delayTime)
        delay.feedback = params.delayFeedback * 100 // 0-100
        delay.wetDryMix = params.delayMix * 100 // 0-100

        delayNode = delay
        return delay
    }

    private func createLowPassUnit(with params: AudioEffectConfig.EffectParameters) -> AVAudioUnit? {
        let eq = AVAudioUnitEQ(numberOfBands: 1)

        let filterParams = eq.bands[0]
        filterParams.filterType = .lowPass
        filterParams.frequency = params.cutoffFrequency
        filterParams.bypass = false

        lowPassNode = eq
        return eq
    }

    private func createHighPassUnit(with params: AudioEffectConfig.EffectParameters) -> AVAudioUnit? {
        let eq = AVAudioUnitEQ(numberOfBands: 1)

        let filterParams = eq.bands[0]
        filterParams.filterType = .highPass
        filterParams.frequency = params.cutoffFrequency
        filterParams.bypass = false

        highPassNode = eq
        return eq
    }

    private func createBandPassUnit(with params: AudioEffectConfig.EffectParameters) -> AVAudioUnit? {
        let eq = AVAudioUnitEQ(numberOfBands: 1)

        let filterParams = eq.bands[0]
        filterParams.filterType = .bandPass
        filterParams.frequency = params.cutoffFrequency
        filterParams.bandwidth = params.bandwidth
        filterParams.bypass = false

        bandPassNode = eq
        return eq
    }

    private func createDistortionUnit(with params: AudioEffectConfig.EffectParameters) -> AVAudioUnit? {
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(.multiDecimated1)
        distortion.wetDryMix = params.distortionMix * 100 // 0-100

        // Adjust pre-gain based on distortion amount
        distortion.preGain = -6 + (params.distortionAmount * 12) // -6 to +6 dB

        distortionNode = distortion
        return distortion
    }

    private func createEQUnit(with params: AudioEffectConfig.EffectParameters) -> AVAudioUnit? {
        let eq = AVAudioUnitEQ(numberOfBands: 3)

        // Low band (80 Hz)
        eq.bands[0].filterType = .parametric
        eq.bands[0].frequency = 80
        eq.bands[0].bandwidth = 1.0
        eq.bands[0].gain = params.eqLowGain
        eq.bands[0].bypass = false

        // Mid band (1000 Hz)
        eq.bands[1].filterType = .parametric
        eq.bands[1].frequency = 1000
        eq.bands[1].bandwidth = 1.0
        eq.bands[1].gain = params.eqMidGain
        eq.bands[1].bypass = false

        // High band (8000 Hz)
        eq.bands[2].filterType = .parametric
        eq.bands[2].frequency = 8000
        eq.bands[2].bandwidth = 1.0
        eq.bands[2].gain = params.eqHighGain
        eq.bands[2].bypass = false

        eqNode = eq
        return eq
    }

    // MARK: - Effect Chain Application

    func applyEffectsToEngine(
        _ engine: AVAudioEngine,
        sourceNode: AVAudioNode,
        format: AVAudioFormat
    ) -> AVAudioNode {
        var currentNode: AVAudioNode = sourceNode

        let effectUnits = createEffectUnits(for: engine)

        for effectUnit in effectUnits {
            engine.attach(effectUnit)
            engine.connect(currentNode, to: effectUnit, format: format)
            currentNode = effectUnit
        }

        return currentNode
    }

    // MARK: - Real-time Parameter Updates

    func updateReverbMix(_ mix: Float) {
        reverbNode?.wetDryMix = mix * 100
    }

    func updateDelayTime(_ time: Float) {
        delayNode?.delayTime = TimeInterval(time)
    }

    func updateDelayMix(_ mix: Float) {
        delayNode?.wetDryMix = mix * 100
    }

    func updateDelayFeedback(_ feedback: Float) {
        delayNode?.feedback = feedback * 100
    }

    func updateFilterCutoff(_ frequency: Float, for effectType: AudioEffectType) {
        switch effectType {
        case .lowPassFilter:
            lowPassNode?.bands[0].frequency = frequency
        case .highPassFilter:
            highPassNode?.bands[0].frequency = frequency
        case .bandPassFilter:
            bandPassNode?.bands[0].frequency = frequency
        default:
            break
        }
    }

    func updateDistortionMix(_ mix: Float) {
        distortionNode?.wetDryMix = mix * 100
    }

    func updateEQGain(band: Int, gain: Float) {
        guard let eq = eqNode, band < eq.bands.count else { return }
        eq.bands[band].gain = gain
    }

    // MARK: - Presets

    static func ambientPreset() -> [AudioEffectConfig] {
        var effects = [
            AudioEffectConfig(effectType: .reverb, isEnabled: true),
            AudioEffectConfig(effectType: .lowPassFilter, isEnabled: true),
            AudioEffectConfig(effectType: .eq, isEnabled: false)
        ]

        effects[0].parameters.reverbMix = 0.5
        effects[0].parameters.reverbSize = 0.7

        effects[1].parameters.cutoffFrequency = 2000

        return effects
    }

    static func deepSpacePreset() -> [AudioEffectConfig] {
        var effects = [
            AudioEffectConfig(effectType: .reverb, isEnabled: true),
            AudioEffectConfig(effectType: .delay, isEnabled: true),
            AudioEffectConfig(effectType: .lowPassFilter, isEnabled: true)
        ]

        effects[0].parameters.reverbMix = 0.7
        effects[0].parameters.reverbSize = 0.9

        effects[1].parameters.delayTime = 0.75
        effects[1].parameters.delayMix = 0.4
        effects[1].parameters.delayFeedback = 0.5

        effects[2].parameters.cutoffFrequency = 3000

        return effects
    }

    static func crystalClearPreset() -> [AudioEffectConfig] {
        var effects = [
            AudioEffectConfig(effectType: .highPassFilter, isEnabled: true),
            AudioEffectConfig(effectType: .eq, isEnabled: true)
        ]

        effects[0].parameters.cutoffFrequency = 100

        effects[1].parameters.eqLowGain = -3
        effects[1].parameters.eqMidGain = 2
        effects[1].parameters.eqHighGain = 3

        return effects
    }

    static func warmPreset() -> [AudioEffectConfig] {
        var effects = [
            AudioEffectConfig(effectType: .lowPassFilter, isEnabled: true),
            AudioEffectConfig(effectType: .eq, isEnabled: true),
            AudioEffectConfig(effectType: .reverb, isEnabled: true)
        ]

        effects[0].parameters.cutoffFrequency = 5000

        effects[1].parameters.eqLowGain = 3
        effects[1].parameters.eqMidGain = 1
        effects[1].parameters.eqHighGain = -2

        effects[2].parameters.reverbMix = 0.2

        return effects
    }
}
