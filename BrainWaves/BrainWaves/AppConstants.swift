//
//  AppConstants.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation

enum AppConstants {

    // MARK: - Audio Configuration

    enum Audio {
        static let sampleRate: Double = 44100.0
        static let bufferSize: AVAudioFrameCount = 22050 // 0.5 seconds
        static let defaultVolume: Float = 0.3 // 30% to prevent clipping

        enum Frequency {
            static let baseMin: Double = 100.0
            static let baseMax: Double = 500.0
            static let beatMin: Double = 0.5
            static let beatMax: Double = 100.0
            static let defaultBase: Double = 200.0
            static let defaultBeat: Double = 10.0
            static let defaultCarrier: Double = 250.0
        }

        enum Brainwave {
            static let deltaMin: Double = 0.0
            static let deltaMax: Double = 4.0
            static let thetaMin: Double = 4.0
            static let thetaMax: Double = 8.0
            static let alphaMin: Double = 8.0
            static let alphaMax: Double = 14.0
            static let betaMin: Double = 14.0
            static let betaMax: Double = 30.0
            static let gammaMin: Double = 30.0
            static let gammaMax: Double = 100.0
        }
    }

    // MARK: - Timer Configuration

    enum Timer {
        static let defaultDuration: TimeInterval = 600.0 // 10 minutes
        static let presetDurations: [TimeInterval] = [300, 600, 900, 1800, 3600]
        static let updateInterval: TimeInterval = 0.1
    }

    // MARK: - UI Configuration

    enum UI {
        static let frequencyStep: Double = 0.5
        static let cornerRadius: CGFloat = 12
        static let standardPadding: CGFloat = 16
        static let componentSpacing: CGFloat = 20
    }

    // MARK: - Persistence Keys

    enum Storage {
        static let binauralPresetsKey = "saved_binaural_presets"
        static let isochronicPresetsKey = "saved_isochronic_presets"
        static let playlistsKey = "playlists"
        static let lastUsedSettingsKey = "last_used_settings"
        static let volumePreferenceKey = "user_volume_preference"
    }

    // MARK: - Audio Effects

    enum AudioEffects {
        static let fadeInDuration: TimeInterval = 2.0
        static let fadeOutDuration: TimeInterval = 2.0
        static let fadeSmoothness: TimeInterval = 0.1 // Update interval for smooth fade
    }

    // MARK: - Waveform Types

    enum WaveformType: String, CaseIterable, Codable {
        case sine = "Sine"
        case square = "Square"
        case triangle = "Triangle"
        case sawtooth = "Sawtooth"
        case whiteNoise = "White Noise"
        case pinkNoise = "Pink Noise"
        case brownNoise = "Brown Noise"

        var description: String {
            switch self {
            case .sine:
                return "Pure sine wave - smooth, traditional"
            case .square:
                return "Square wave - sharp, intense"
            case .triangle:
                return "Triangle wave - smooth, mellow"
            case .sawtooth:
                return "Sawtooth wave - bright, energetic"
            case .whiteNoise:
                return "White noise - all frequencies equal"
            case .pinkNoise:
                return "Pink noise - natural, soothing"
            case .brownNoise:
                return "Brown noise - deep, rumbling"
            }
        }

        var icon: String {
            switch self {
            case .sine:
                return "waveform"
            case .square:
                return "square"
            case .triangle:
                return "triangle"
            case .sawtooth:
                return "waveform.path"
            case .whiteNoise, .pinkNoise, .brownNoise:
                return "waveform.circle"
            }
        }
    }

    // MARK: - Frequency Ramping

    enum RampType: String, CaseIterable, Codable {
        case none = "No Ramp"
        case ascending = "Ascending"
        case descending = "Descending"
        case ascendingDescending = "Ascending then Descending"
        case descendingAscending = "Descending then Ascending"

        var description: String {
            switch self {
            case .none:
                return "Constant frequency"
            case .ascending:
                return "Gradually increase frequency"
            case .descending:
                return "Gradually decrease frequency"
            case .ascendingDescending:
                return "Increase then decrease"
            case .descendingAscending:
                return "Decrease then increase"
            }
        }

        var icon: String {
            switch self {
            case .none:
                return "minus"
            case .ascending:
                return "arrow.up.right"
            case .descending:
                return "arrow.down.right"
            case .ascendingDescending:
                return "arrow.up.and.down"
            case .descendingAscending:
                return "arrow.down.and.up"
            }
        }
    }

    enum RampCurve: String, CaseIterable, Codable {
        case linear = "Linear"
        case exponential = "Exponential"
        case logarithmic = "Logarithmic"

        var description: String {
            switch self {
            case .linear:
                return "Steady, even progression"
            case .exponential:
                return "Slow start, fast finish"
            case .logarithmic:
                return "Fast start, slow finish"
            }
        }
    }

    // MARK: - Brainwave Types

    enum BrainwaveType: String {
        case delta = "Delta - Deep Sleep"
        case theta = "Theta - Meditation"
        case alpha = "Alpha - Relaxation"
        case beta = "Beta - Focus"
        case gamma = "Gamma - Peak Awareness"
        case custom = "Custom"

        static func type(for frequency: Double) -> BrainwaveType {
            switch frequency {
            case Audio.Brainwave.deltaMin..<Audio.Brainwave.deltaMax:
                return .delta
            case Audio.Brainwave.thetaMin..<Audio.Brainwave.thetaMax:
                return .theta
            case Audio.Brainwave.alphaMin..<Audio.Brainwave.alphaMax:
                return .alpha
            case Audio.Brainwave.betaMin..<Audio.Brainwave.betaMax:
                return .beta
            case Audio.Brainwave.gammaMin...Audio.Brainwave.gammaMax:
                return .gamma
            default:
                return .custom
            }
        }
    }
}
