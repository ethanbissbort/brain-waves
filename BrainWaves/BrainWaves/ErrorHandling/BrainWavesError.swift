//
//  BrainWavesError.swift
//  BrainWaves
//
//  Comprehensive error type definitions for the application
//

import Foundation

/// Root error protocol for all Brain Waves errors
protocol BrainWavesError: LocalizedError {
    var errorCode: String { get }
    var recoverySuggestion: String? { get }
}

// MARK: - Audio Errors

/// Errors related to audio generation and playback
enum AudioError: BrainWavesError {
    case engineNotConfigured
    case engineFailedToStart
    case invalidFrequency(Double)
    case invalidDuration(TimeInterval)
    case bufferCreationFailed
    case sessionConfigurationFailed(Error)
    case sessionActivationFailed(Error)
    case nodeAttachmentFailed
    case formatCreationFailed
    case playerNodeNotReady

    var errorCode: String {
        switch self {
        case .engineNotConfigured: return "AUDIO_001"
        case .engineFailedToStart: return "AUDIO_002"
        case .invalidFrequency: return "AUDIO_003"
        case .invalidDuration: return "AUDIO_004"
        case .bufferCreationFailed: return "AUDIO_005"
        case .sessionConfigurationFailed: return "AUDIO_006"
        case .sessionActivationFailed: return "AUDIO_007"
        case .nodeAttachmentFailed: return "AUDIO_008"
        case .formatCreationFailed: return "AUDIO_009"
        case .playerNodeNotReady: return "AUDIO_010"
        }
    }

    var errorDescription: String? {
        switch self {
        case .engineNotConfigured:
            return "Audio engine is not properly configured"
        case .engineFailedToStart:
            return "Failed to start audio engine"
        case .invalidFrequency(let freq):
            return "Invalid frequency value: \(freq) Hz"
        case .invalidDuration(let duration):
            return "Invalid duration: \(duration) seconds"
        case .bufferCreationFailed:
            return "Failed to create audio buffer"
        case .sessionConfigurationFailed(let error):
            return "Audio session configuration failed: \(error.localizedDescription)"
        case .sessionActivationFailed(let error):
            return "Audio session activation failed: \(error.localizedDescription)"
        case .nodeAttachmentFailed:
            return "Failed to attach audio node to engine"
        case .formatCreationFailed:
            return "Failed to create audio format"
        case .playerNodeNotReady:
            return "Audio player node is not ready"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .engineNotConfigured, .engineFailedToStart:
            return "Try restarting the audio session or reopening the app"
        case .invalidFrequency:
            return "Use a frequency between \(AppConstants.Audio.Frequency.beatMin) and \(AppConstants.Audio.Frequency.beatMax) Hz"
        case .invalidDuration:
            return "Use a positive duration value"
        case .bufferCreationFailed, .formatCreationFailed:
            return "This may be a temporary issue. Try again in a moment"
        case .sessionConfigurationFailed, .sessionActivationFailed:
            return "Check your device audio settings and ensure no other apps are blocking audio"
        case .nodeAttachmentFailed:
            return "Restart the app to reset the audio engine"
        case .playerNodeNotReady:
            return "Wait a moment and try playing again"
        }
    }
}

// MARK: - Persistence Errors

/// Errors related to data persistence and storage
enum PersistenceError: BrainWavesError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case saveFailed(String)
    case loadFailed(String)
    case validationFailed(String)
    case migrationFailed(String)
    case presetNotFound(UUID)
    case playlistNotFound(UUID)
    case duplicatePreset(String)

    var errorCode: String {
        switch self {
        case .encodingFailed: return "PERSIST_001"
        case .decodingFailed: return "PERSIST_002"
        case .saveFailed: return "PERSIST_003"
        case .loadFailed: return "PERSIST_004"
        case .validationFailed: return "PERSIST_005"
        case .migrationFailed: return "PERSIST_006"
        case .presetNotFound: return "PERSIST_007"
        case .playlistNotFound: return "PERSIST_008"
        case .duplicatePreset: return "PERSIST_009"
        }
    }

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .saveFailed(let key):
            return "Failed to save data for key: \(key)"
        case .loadFailed(let key):
            return "Failed to load data for key: \(key)"
        case .validationFailed(let reason):
            return "Data validation failed: \(reason)"
        case .migrationFailed(let reason):
            return "Data migration failed: \(reason)"
        case .presetNotFound(let id):
            return "Preset with ID \(id) not found"
        case .playlistNotFound(let id):
            return "Playlist with ID \(id) not found"
        case .duplicatePreset(let name):
            return "A preset named '\(name)' already exists"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .encodingFailed, .decodingFailed:
            return "The data format may be corrupted. Try resetting to defaults"
        case .saveFailed, .loadFailed:
            return "Check available storage space and app permissions"
        case .validationFailed:
            return "Ensure all values are within valid ranges"
        case .migrationFailed:
            return "Try reinstalling the app (note: this will delete all saved data)"
        case .presetNotFound, .playlistNotFound:
            return "The item may have been deleted. Refresh the list"
        case .duplicatePreset:
            return "Choose a different name for your preset"
        }
    }
}

// MARK: - Validation Errors

/// Errors related to input validation
enum ValidationError: BrainWavesError {
    case emptyName
    case nameTooLong(Int)
    case frequencyOutOfRange(Double, min: Double, max: Double)
    case durationOutOfRange(TimeInterval, min: TimeInterval, max: TimeInterval)
    case volumeOutOfRange(Float)
    case invalidPlaylistOrder
    case emptyPlaylist

    var errorCode: String {
        switch self {
        case .emptyName: return "VALID_001"
        case .nameTooLong: return "VALID_002"
        case .frequencyOutOfRange: return "VALID_003"
        case .durationOutOfRange: return "VALID_004"
        case .volumeOutOfRange: return "VALID_005"
        case .invalidPlaylistOrder: return "VALID_006"
        case .emptyPlaylist: return "VALID_007"
        }
    }

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Name cannot be empty"
        case .nameTooLong(let length):
            return "Name is too long (\(length) characters)"
        case .frequencyOutOfRange(let value, let min, let max):
            return "Frequency \(value) Hz is out of range (\(min)-\(max) Hz)"
        case .durationOutOfRange(let value, let min, let max):
            return "Duration \(value)s is out of range (\(min)-\(max) seconds)"
        case .volumeOutOfRange(let value):
            return "Volume \(value) is out of range (0.0-1.0)"
        case .invalidPlaylistOrder:
            return "Playlist item order is invalid"
        case .emptyPlaylist:
            return "Playlist cannot be empty"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .emptyName:
            return "Enter a name for your preset or playlist"
        case .nameTooLong:
            return "Use a shorter name (maximum 100 characters)"
        case .frequencyOutOfRange(_, let min, let max):
            return "Use a frequency between \(min) and \(max) Hz"
        case .durationOutOfRange(_, let min, let max):
            return "Use a duration between \(min) and \(max) seconds"
        case .volumeOutOfRange:
            return "Use a volume between 0.0 and 1.0"
        case .invalidPlaylistOrder:
            return "Reorder playlist items to fix gaps in numbering"
        case .emptyPlaylist:
            return "Add at least one preset to the playlist before saving"
        }
    }
}

// MARK: - General Errors

/// General application errors
enum GeneralError: BrainWavesError {
    case unexpectedNil(String)
    case invalidState(String)
    case operationCancelled
    case notImplemented(String)

    var errorCode: String {
        switch self {
        case .unexpectedNil: return "GEN_001"
        case .invalidState: return "GEN_002"
        case .operationCancelled: return "GEN_003"
        case .notImplemented: return "GEN_004"
        }
    }

    var errorDescription: String? {
        switch self {
        case .unexpectedNil(let item):
            return "Unexpected nil value for: \(item)"
        case .invalidState(let description):
            return "Invalid state: \(description)"
        case .operationCancelled:
            return "Operation was cancelled"
        case .notImplemented(let feature):
            return "Feature not yet implemented: \(feature)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unexpectedNil, .invalidState:
            return "This is likely a bug. Please restart the app and report if it persists"
        case .operationCancelled:
            return nil
        case .notImplemented:
            return "This feature is coming in a future update"
        }
    }
}
