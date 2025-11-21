//
//  Protocols.swift
//  BrainWaves
//
//  Protocol definitions for dependency injection
//  Enables loose coupling and testability
//

import Foundation
import Combine

// MARK: - Persistence Protocols

/// Protocol for preset storage operations
protocol PresetStoreProtocol: AnyObject {
    var binauralPresets: [BinauralBeatPreset] { get }
    var isochronicPresets: [IsochronicTonePreset] { get }
    var playlists: [Playlist] { get }

    func addBinauralPreset(_ preset: BinauralBeatPreset)
    func updateBinauralPreset(_ preset: BinauralBeatPreset)
    func deleteBinauralPreset(_ preset: BinauralBeatPreset)

    func addIsochronicPreset(_ preset: IsochronicTonePreset)
    func updateIsochronicPreset(_ preset: IsochronicTonePreset)
    func deleteIsochronicPreset(_ preset: IsochronicTonePreset)

    func addPlaylist(_ playlist: Playlist)
    func updatePlaylist(_ playlist: Playlist)
    func deletePlaylist(_ playlist: Playlist)
}

/// Protocol for settings management
protocol SettingsManagerProtocol: AnyObject {
    var volume: Float { get set }
    func resetToDefaults()
}

// MARK: - Manager Protocols

/// Protocol for audio session management
protocol AudioSessionManagerProtocol: AnyObject {
    var isInterrupted: Bool { get }
    func configureAudioSession() throws
    func handleInterruption(type: InterruptionType)
}

/// Interruption type for audio session
enum InterruptionType {
    case began
    case ended
}

/// Protocol for haptic feedback
protocol HapticManagerProtocol: AnyObject {
    func lightImpact()
    func mediumImpact()
    func heavyImpact()
    func selectionChanged()
    func success()
    func warning()
    func error()
}

/// Protocol for preset coordination
protocol PresetCoordinatorProtocol: AnyObject {
    var selectedBinauralPreset: BinauralBeatPreset? { get set }
    var selectedIsochronicPreset: IsochronicTonePreset? { get set }
    var shouldNavigateToBinaural: Bool { get set }
    var shouldNavigateToIsochronic: Bool { get set }

    func selectBinauralPreset(_ preset: BinauralBeatPreset)
    func selectIsochronicPreset(_ preset: IsochronicTonePreset)
    func clearBinauralPreset()
    func clearIsochronicPreset()
}

// MARK: - Generator Protocols

/// Protocol for binaural beats generator
protocol BinauralBeatsGeneratorProtocol: AudioGenerator {
    func start(baseFrequency: Double, beatFrequency: Double, duration: TimeInterval)
}

/// Protocol for isochronic tones generator
protocol IsochronicTonesGeneratorProtocol: AudioGenerator {
    func start(carrierFrequency: Double, pulseFrequency: Double, duration: TimeInterval)
}
