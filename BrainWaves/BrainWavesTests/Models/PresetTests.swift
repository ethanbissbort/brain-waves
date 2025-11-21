//
//  PresetTests.swift
//  BrainWavesTests
//
//  Unit tests for preset models
//

import XCTest
@testable import BrainWaves

final class PresetTests: XCTestCase {

    // MARK: - BinauralBeatPreset Tests

    func testBinauralBeatPresetCreation() {
        let preset = BinauralBeatPreset(
            id: UUID(),
            name: "Test Preset",
            baseFrequency: 200.0,
            beatFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertEqual(preset.name, "Test Preset")
        XCTAssertEqual(preset.baseFrequency, 200.0)
        XCTAssertEqual(preset.beatFrequency, 10.0)
        XCTAssertEqual(preset.duration, 600.0)
    }

    func testBinauralBeatPresetCoding() throws {
        let preset = BinauralBeatPreset(
            id: UUID(),
            name: "Test Preset",
            baseFrequency: 200.0,
            beatFrequency: 10.0,
            duration: 600.0
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(preset)

        // Decode
        let decoder = JSONDecoder()
        let decodedPreset = try decoder.decode(BinauralBeatPreset.self, from: data)

        XCTAssertEqual(decodedPreset.id, preset.id)
        XCTAssertEqual(decodedPreset.name, preset.name)
        XCTAssertEqual(decodedPreset.baseFrequency, preset.baseFrequency)
        XCTAssertEqual(decodedPreset.beatFrequency, preset.beatFrequency)
        XCTAssertEqual(decodedPreset.duration, preset.duration)
    }

    func testBinauralBeatPresetEquality() {
        let id = UUID()
        let preset1 = BinauralBeatPreset(
            id: id,
            name: "Test",
            baseFrequency: 200.0,
            beatFrequency: 10.0,
            duration: 600.0
        )

        let preset2 = BinauralBeatPreset(
            id: id,
            name: "Test",
            baseFrequency: 200.0,
            beatFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertEqual(preset1, preset2)
    }

    func testBinauralBeatPresetDefaultPresets() {
        let defaults = BinauralBeatPreset.defaultPresets

        XCTAssertFalse(defaults.isEmpty)
        XCTAssertEqual(defaults.count, 5)

        // Test that all default presets have unique IDs
        let uniqueIds = Set(defaults.map { $0.id })
        XCTAssertEqual(uniqueIds.count, defaults.count)

        // Test that all default presets have valid values
        for preset in defaults {
            XCTAssertFalse(preset.name.isEmpty)
            XCTAssertGreaterThanOrEqual(preset.baseFrequency, AppConstants.Audio.Frequency.baseMin)
            XCTAssertLessThanOrEqual(preset.baseFrequency, AppConstants.Audio.Frequency.baseMax)
            XCTAssertGreaterThanOrEqual(preset.beatFrequency, AppConstants.Audio.Frequency.beatMin)
            XCTAssertLessThanOrEqual(preset.beatFrequency, AppConstants.Audio.Frequency.beatMax)
            XCTAssertGreaterThan(preset.duration, 0)
        }
    }

    // MARK: - IsochronicTonePreset Tests

    func testIsochronicTonePresetCreation() {
        let preset = IsochronicTonePreset(
            id: UUID(),
            name: "Test Preset",
            carrierFrequency: 250.0,
            pulseFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertEqual(preset.name, "Test Preset")
        XCTAssertEqual(preset.carrierFrequency, 250.0)
        XCTAssertEqual(preset.pulseFrequency, 10.0)
        XCTAssertEqual(preset.duration, 600.0)
    }

    func testIsochronicTonePresetCoding() throws {
        let preset = IsochronicTonePreset(
            id: UUID(),
            name: "Test Preset",
            carrierFrequency: 250.0,
            pulseFrequency: 10.0,
            duration: 600.0
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(preset)

        // Decode
        let decoder = JSONDecoder()
        let decodedPreset = try decoder.decode(IsochronicTonePreset.self, from: data)

        XCTAssertEqual(decodedPreset.id, preset.id)
        XCTAssertEqual(decodedPreset.name, preset.name)
        XCTAssertEqual(decodedPreset.carrierFrequency, preset.carrierFrequency)
        XCTAssertEqual(decodedPreset.pulseFrequency, preset.pulseFrequency)
        XCTAssertEqual(decodedPreset.duration, preset.duration)
    }

    func testIsochronicTonePresetDefaultPresets() {
        let defaults = IsochronicTonePreset.defaultPresets

        XCTAssertFalse(defaults.isEmpty)
        XCTAssertEqual(defaults.count, 5)

        // Test that all default presets have valid values
        for preset in defaults {
            XCTAssertFalse(preset.name.isEmpty)
            XCTAssertGreaterThanOrEqual(preset.carrierFrequency, AppConstants.Audio.Frequency.baseMin)
            XCTAssertLessThanOrEqual(preset.carrierFrequency, AppConstants.Audio.Frequency.baseMax)
            XCTAssertGreaterThanOrEqual(preset.pulseFrequency, AppConstants.Audio.Frequency.beatMin)
            XCTAssertLessThanOrEqual(preset.pulseFrequency, AppConstants.Audio.Frequency.beatMax)
            XCTAssertGreaterThan(preset.duration, 0)
        }
    }

    // MARK: - Playlist Tests

    func testPlaylistCreation() {
        let playlist = Playlist(
            id: UUID(),
            name: "Test Playlist",
            items: [],
            createdDate: Date(),
            modifiedDate: Date()
        )

        XCTAssertEqual(playlist.name, "Test Playlist")
        XCTAssertTrue(playlist.items.isEmpty)
    }

    func testPlaylistAddItem() {
        var playlist = Playlist(
            id: UUID(),
            name: "Test Playlist",
            items: [],
            createdDate: Date(),
            modifiedDate: Date()
        )

        let item = PlaylistItem(
            id: UUID(),
            presetId: UUID(),
            type: .binaural,
            order: 0
        )

        playlist.addItem(item)

        XCTAssertEqual(playlist.items.count, 1)
        XCTAssertEqual(playlist.items[0].id, item.id)
    }

    func testPlaylistRemoveItem() {
        let item = PlaylistItem(
            id: UUID(),
            presetId: UUID(),
            type: .binaural,
            order: 0
        )

        var playlist = Playlist(
            id: UUID(),
            name: "Test Playlist",
            items: [item],
            createdDate: Date(),
            modifiedDate: Date()
        )

        playlist.removeItem(withId: item.id)

        XCTAssertTrue(playlist.items.isEmpty)
    }

    func testPlaylistMoveItem() {
        let items = [
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 0),
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 1),
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 2)
        ]

        var playlist = Playlist(
            id: UUID(),
            name: "Test Playlist",
            items: items,
            createdDate: Date(),
            modifiedDate: Date()
        )

        playlist.moveItem(from: 0, to: 2)

        XCTAssertEqual(playlist.items[0].order, 0)
        XCTAssertEqual(playlist.items[1].order, 1)
        XCTAssertEqual(playlist.items[2].order, 2)
    }

    func testPlaylistCoding() throws {
        let playlist = Playlist(
            id: UUID(),
            name: "Test Playlist",
            items: [],
            createdDate: Date(),
            modifiedDate: Date()
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(playlist)

        // Decode
        let decoder = JSONDecoder()
        let decodedPlaylist = try decoder.decode(Playlist.self, from: data)

        XCTAssertEqual(decodedPlaylist.id, playlist.id)
        XCTAssertEqual(decodedPlaylist.name, playlist.name)
        XCTAssertEqual(decodedPlaylist.items.count, playlist.items.count)
    }
}
