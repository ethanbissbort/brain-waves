//
//  DataValidatorTests.swift
//  BrainWavesTests
//
//  Unit tests for data validation
//

import XCTest
@testable import BrainWaves

final class DataValidatorTests: XCTestCase {

    // MARK: - Name Validation Tests

    func testValidateName_Success() {
        XCTAssertNoThrow(try DataValidator.validateName("Valid Name"))
        XCTAssertNoThrow(try DataValidator.validateName("A"))
        XCTAssertNoThrow(try DataValidator.validateName("Name with spaces"))
    }

    func testValidateName_EmptyFails() {
        XCTAssertThrowsError(try DataValidator.validateName("")) { error in
            XCTAssertTrue(error is ValidationError)
            if case ValidationError.emptyName = error {
                // Success
            } else {
                XCTFail("Expected ValidationError.emptyName")
            }
        }
    }

    func testValidateName_WhitespaceOnlyFails() {
        XCTAssertThrowsError(try DataValidator.validateName("   ")) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testValidateName_TooLongFails() {
        let longName = String(repeating: "a", count: 101)
        XCTAssertThrowsError(try DataValidator.validateName(longName)) { error in
            XCTAssertTrue(error is ValidationError)
            if case ValidationError.nameTooLong = error {
                // Success
            } else {
                XCTFail("Expected ValidationError.nameTooLong")
            }
        }
    }

    // MARK: - Duration Validation Tests

    func testValidateDuration_Success() {
        XCTAssertNoThrow(try DataValidator.validateDuration(60)) // 1 minute
        XCTAssertNoThrow(try DataValidator.validateDuration(600)) // 10 minutes
        XCTAssertNoThrow(try DataValidator.validateDuration(3600)) // 1 hour
    }

    func testValidateDuration_TooShortFails() {
        XCTAssertThrowsError(try DataValidator.validateDuration(30)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testValidateDuration_TooLongFails() {
        XCTAssertThrowsError(try DataValidator.validateDuration(20000)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    // MARK: - Volume Validation Tests

    func testValidateVolume_Success() {
        XCTAssertNoThrow(try DataValidator.validateVolume(0.0))
        XCTAssertNoThrow(try DataValidator.validateVolume(0.5))
        XCTAssertNoThrow(try DataValidator.validateVolume(1.0))
    }

    func testValidateVolume_OutOfRangeFails() {
        XCTAssertThrowsError(try DataValidator.validateVolume(-0.1))
        XCTAssertThrowsError(try DataValidator.validateVolume(1.1))
    }

    // MARK: - Frequency Validation Tests

    func testValidateFrequency_Success() {
        XCTAssertNoThrow(try DataValidator.validateFrequency(10.0, min: 0.5, max: 100.0))
        XCTAssertNoThrow(try DataValidator.validateFrequency(0.5, min: 0.5, max: 100.0))
        XCTAssertNoThrow(try DataValidator.validateFrequency(100.0, min: 0.5, max: 100.0))
    }

    func testValidateFrequency_OutOfRangeFails() {
        XCTAssertThrowsError(try DataValidator.validateFrequency(0.4, min: 0.5, max: 100.0))
        XCTAssertThrowsError(try DataValidator.validateFrequency(100.1, min: 0.5, max: 100.0))
    }

    // MARK: - Binaural Preset Validation Tests

    func testValidateBinauralPreset_Success() {
        let preset = BinauralBeatPreset(
            id: UUID(),
            name: "Valid Preset",
            baseFrequency: 200.0,
            beatFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertNoThrow(try DataValidator.validate(binauralPreset: preset))
    }

    func testValidateBinauralPreset_InvalidName() {
        let preset = BinauralBeatPreset(
            id: UUID(),
            name: "",
            baseFrequency: 200.0,
            beatFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertThrowsError(try DataValidator.validate(binauralPreset: preset))
    }

    func testValidateBinauralPreset_InvalidBaseFrequency() {
        let preset = BinauralBeatPreset(
            id: UUID(),
            name: "Test",
            baseFrequency: 50.0, // Too low
            beatFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertThrowsError(try DataValidator.validate(binauralPreset: preset))
    }

    func testValidateBinauralPreset_InvalidBeatFrequency() {
        let preset = BinauralBeatPreset(
            id: UUID(),
            name: "Test",
            baseFrequency: 200.0,
            beatFrequency: 150.0, // Too high
            duration: 600.0
        )

        XCTAssertThrowsError(try DataValidator.validate(binauralPreset: preset))
    }

    // MARK: - Isochronic Preset Validation Tests

    func testValidateIsochronicPreset_Success() {
        let preset = IsochronicTonePreset(
            id: UUID(),
            name: "Valid Preset",
            carrierFrequency: 250.0,
            pulseFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertNoThrow(try DataValidator.validate(isochronicPreset: preset))
    }

    func testValidateIsochronicPreset_InvalidCarrierFrequency() {
        let preset = IsochronicTonePreset(
            id: UUID(),
            name: "Test",
            carrierFrequency: 600.0, // Too high
            pulseFrequency: 10.0,
            duration: 600.0
        )

        XCTAssertThrowsError(try DataValidator.validate(isochronicPreset: preset))
    }

    // MARK: - Playlist Validation Tests

    func testValidatePlaylist_Success() {
        let playlist = Playlist(
            id: UUID(),
            name: "Valid Playlist",
            items: [
                PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 0)
            ],
            createdDate: Date(),
            modifiedDate: Date()
        )

        XCTAssertNoThrow(try DataValidator.validate(playlist: playlist))
    }

    func testValidatePlaylist_EmptyFails() {
        let playlist = Playlist(
            id: UUID(),
            name: "Empty Playlist",
            items: [],
            createdDate: Date(),
            modifiedDate: Date()
        )

        XCTAssertThrowsError(try DataValidator.validate(playlist: playlist)) { error in
            if case ValidationError.emptyPlaylist = error {
                // Success
            } else {
                XCTFail("Expected ValidationError.emptyPlaylist")
            }
        }
    }

    func testValidatePlaylist_InvalidOrderFails() {
        let playlist = Playlist(
            id: UUID(),
            name: "Invalid Order",
            items: [
                PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 0),
                PlaylistItem(id: UUID(), presetId: UUID(), type: .binaural, order: 2) // Gap in order
            ],
            createdDate: Date(),
            modifiedDate: Date()
        )

        XCTAssertThrowsError(try DataValidator.validate(playlist: playlist)) { error in
            if case ValidationError.invalidPlaylistOrder = error {
                // Success
            } else {
                XCTFail("Expected ValidationError.invalidPlaylistOrder")
            }
        }
    }
}
