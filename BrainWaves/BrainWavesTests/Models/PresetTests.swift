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

        let presetId = UUID()
        playlist.addItem(presetId: presetId, type: .binaural)

        XCTAssertEqual(playlist.items.count, 1)
        XCTAssertEqual(playlist.items[0].presetId, presetId)
        XCTAssertEqual(playlist.items[0].type, .binaural)
        XCTAssertEqual(playlist.items[0].order, 0)
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

        playlist.removeItem(at: 0)

        XCTAssertTrue(playlist.items.isEmpty)
    }

    func testPlaylistMoveItem() {
        let items = [
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 0),
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 1),
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 2)
        ]

        let firstPresetId = items[0].presetId

        var playlist = Playlist(
            id: UUID(),
            name: "Test Playlist",
            items: items,
            createdDate: Date(),
            modifiedDate: Date()
        )

        playlist.moveItem(from: 0, to: 2)

        // Orders are always reindexed to be contiguous...
        XCTAssertEqual(playlist.items[0].order, 0)
        XCTAssertEqual(playlist.items[1].order, 1)
        XCTAssertEqual(playlist.items[2].order, 2)

        // ...and the moved item actually lands at the new position.
        XCTAssertEqual(playlist.items[2].presetId, firstPresetId)
    }

    func testPlaylistMoveItemToEndDoesNotCrash() {
        let items = [
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 0),
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 1),
            PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 2)
        ]
        let firstPresetId = items[0].presetId

        var playlist = Playlist(
            id: UUID(),
            name: "Test Playlist",
            items: items,
            createdDate: Date(),
            modifiedDate: Date()
        )

        // `to` equal to items.count is a valid "move to end" request (e.g. from SwiftUI onMove);
        // it must not trap on the post-removal insertion index.
        playlist.moveItem(from: 0, to: 3)

        XCTAssertEqual(playlist.items.count, 3)
        XCTAssertEqual(playlist.items[2].presetId, firstPresetId)
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

    // MARK: - Legacy (pre-Phase-2) Decoding Tests

    // These lock in backward-compatibility: data saved before waveformType/rampConfig/category/tags
    // and the playlist playback settings existed must still decode (previously it threw keyNotFound
    // and the store's `try?` silently discarded all of the user's saved data).

    func testBinauralBeatPresetDecodesLegacyDataWithoutPhase2Fields() throws {
        let legacyJSON = """
        {
            "id": "11111111-1111-1111-1111-111111111111",
            "name": "Legacy Preset",
            "baseFrequency": 200,
            "beatFrequency": 10,
            "duration": 600
        }
        """
        let data = Data(legacyJSON.utf8)

        let preset = try JSONDecoder().decode(BinauralBeatPreset.self, from: data)

        XCTAssertEqual(preset.name, "Legacy Preset")
        XCTAssertEqual(preset.baseFrequency, 200)
        XCTAssertEqual(preset.beatFrequency, 10)
        XCTAssertEqual(preset.waveformType, .sine)
        XCTAssertEqual(preset.category, .custom)
        XCTAssertTrue(preset.tags.isEmpty)
        XCTAssertNil(preset.rampConfig)
    }

    func testIsochronicTonePresetDecodesLegacyDataWithoutPhase2Fields() throws {
        let legacyJSON = """
        {
            "id": "22222222-2222-2222-2222-222222222222",
            "name": "Legacy Iso",
            "carrierFrequency": 250,
            "pulseFrequency": 10,
            "duration": 600
        }
        """
        let data = Data(legacyJSON.utf8)

        let preset = try JSONDecoder().decode(IsochronicTonePreset.self, from: data)

        XCTAssertEqual(preset.name, "Legacy Iso")
        XCTAssertEqual(preset.carrierFrequency, 250)
        XCTAssertEqual(preset.pulseFrequency, 10)
        XCTAssertEqual(preset.waveformType, .sine)
        XCTAssertEqual(preset.category, .custom)
        XCTAssertTrue(preset.tags.isEmpty)
        XCTAssertNil(preset.rampConfig)
    }

    func testPlaylistDecodesLegacyDataWithoutPlaybackSettings() throws {
        let legacyJSON = """
        {
            "id": "33333333-3333-3333-3333-333333333333",
            "name": "Legacy Playlist",
            "items": [],
            "createdDate": 700000000,
            "modifiedDate": 700000000
        }
        """
        let data = Data(legacyJSON.utf8)

        let playlist = try JSONDecoder().decode(Playlist.self, from: data)

        XCTAssertEqual(playlist.name, "Legacy Playlist")
        XCTAssertFalse(playlist.shuffleEnabled)
        XCTAssertEqual(playlist.repeatMode, .off)
        XCTAssertEqual(playlist.crossfadeDuration, 3.0)
    }
}
