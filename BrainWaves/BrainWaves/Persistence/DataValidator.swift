//
//  DataValidator.swift
//  BrainWaves
//
//  Data validation for models and user input
//

import Foundation

/// Protocol for validatable data models
protocol Validatable {
    func validate() throws
}

/// Data validator for presets and playlists
struct DataValidator {

    // MARK: - Constants

    private static let maxNameLength = 100
    private static let minDuration: TimeInterval = 60 // 1 minute
    private static let maxDuration: TimeInterval = 14400 // 4 hours

    // MARK: - Binaural Beat Validation

    static func validate(binauralPreset: BinauralBeatPreset) throws {
        // Validate name
        try validateName(binauralPreset.name)

        // Validate base frequency
        if binauralPreset.baseFrequency < AppConstants.Audio.Frequency.baseMin ||
           binauralPreset.baseFrequency > AppConstants.Audio.Frequency.baseMax {
            throw ValidationError.frequencyOutOfRange(
                binauralPreset.baseFrequency,
                min: AppConstants.Audio.Frequency.baseMin,
                max: AppConstants.Audio.Frequency.baseMax
            )
        }

        // Validate beat frequency
        if binauralPreset.beatFrequency < AppConstants.Audio.Frequency.beatMin ||
           binauralPreset.beatFrequency > AppConstants.Audio.Frequency.beatMax {
            throw ValidationError.frequencyOutOfRange(
                binauralPreset.beatFrequency,
                min: AppConstants.Audio.Frequency.beatMin,
                max: AppConstants.Audio.Frequency.beatMax
            )
        }

        // Validate duration
        try validateDuration(binauralPreset.duration)
    }

    // MARK: - Isochronic Tone Validation

    static func validate(isochronicPreset: IsochronicTonePreset) throws {
        // Validate name
        try validateName(isochronicPreset.name)

        // Validate carrier frequency
        if isochronicPreset.carrierFrequency < AppConstants.Audio.Frequency.baseMin ||
           isochronicPreset.carrierFrequency > AppConstants.Audio.Frequency.baseMax {
            throw ValidationError.frequencyOutOfRange(
                isochronicPreset.carrierFrequency,
                min: AppConstants.Audio.Frequency.baseMin,
                max: AppConstants.Audio.Frequency.baseMax
            )
        }

        // Validate pulse frequency
        if isochronicPreset.pulseFrequency < AppConstants.Audio.Frequency.beatMin ||
           isochronicPreset.pulseFrequency > AppConstants.Audio.Frequency.beatMax {
            throw ValidationError.frequencyOutOfRange(
                isochronicPreset.pulseFrequency,
                min: AppConstants.Audio.Frequency.beatMin,
                max: AppConstants.Audio.Frequency.beatMax
            )
        }

        // Validate duration
        try validateDuration(isochronicPreset.duration)
    }

    // MARK: - Playlist Validation

    static func validate(playlist: Playlist) throws {
        // Validate name
        try validateName(playlist.name)

        // Check if playlist is empty
        if playlist.items.isEmpty {
            throw ValidationError.emptyPlaylist
        }

        // Validate item order
        let orders = playlist.items.map { $0.order }
        let expectedOrders = Array(0..<playlist.items.count)
        if Set(orders) != Set(expectedOrders) {
            throw ValidationError.invalidPlaylistOrder
        }
    }

    // MARK: - Common Validation

    static func validateName(_ name: String) throws {
        // Check for empty name
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            throw ValidationError.emptyName
        }

        // Check name length
        if name.count > maxNameLength {
            throw ValidationError.nameTooLong(name.count)
        }
    }

    static func validateDuration(_ duration: TimeInterval) throws {
        if duration < minDuration || duration > maxDuration {
            throw ValidationError.durationOutOfRange(
                duration,
                min: minDuration,
                max: maxDuration
            )
        }
    }

    static func validateVolume(_ volume: Float) throws {
        if volume < 0.0 || volume > 1.0 {
            throw ValidationError.volumeOutOfRange(volume)
        }
    }

    static func validateFrequency(_ frequency: Double, min: Double, max: Double) throws {
        if frequency < min || frequency > max {
            throw ValidationError.frequencyOutOfRange(frequency, min: min, max: max)
        }
    }
}

// MARK: - Model Extensions

extension BinauralBeatPreset: Validatable {
    func validate() throws {
        try DataValidator.validate(binauralPreset: self)
    }
}

extension IsochronicTonePreset: Validatable {
    func validate() throws {
        try DataValidator.validate(isochronicPreset: self)
    }
}

extension Playlist: Validatable {
    func validate() throws {
        try DataValidator.validate(playlist: self)
    }
}
