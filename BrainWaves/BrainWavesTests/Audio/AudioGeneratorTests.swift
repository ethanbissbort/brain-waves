//
//  AudioGeneratorTests.swift
//  BrainWavesTests
//
//  Unit tests for audio generator base class
//

import XCTest
import AVFoundation
import Combine
@testable import BrainWaves

final class AudioGeneratorTests: XCTestCase {

    var generator: MockAudioGenerator!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        generator = MockAudioGenerator()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        generator = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertFalse(generator.isPlaying)
        XCTAssertEqual(generator.currentTime, 0)
        XCTAssertEqual(generator.duration, 0)
        XCTAssertEqual(generator.volume, AppConstants.Audio.defaultVolume)
    }

    // MARK: - Volume Tests

    func testSetVolume() {
        let newVolume: Float = 0.7
        generator.setVolume(newVolume)

        XCTAssertEqual(generator.volume, newVolume)
    }

    func testVolumeRange() {
        // Test minimum
        generator.setVolume(0.0)
        XCTAssertEqual(generator.volume, 0.0)

        // Test maximum
        generator.setVolume(1.0)
        XCTAssertEqual(generator.volume, 1.0)

        // Test clamping (values outside range should be clamped)
        generator.setVolume(1.5)
        XCTAssertLessThanOrEqual(generator.volume, 1.0)

        generator.setVolume(-0.5)
        XCTAssertGreaterThanOrEqual(generator.volume, 0.0)
    }

    // MARK: - Playback State Tests

    func testStartPlayback() {
        generator.duration = 60.0
        generator.mockStart()

        XCTAssertTrue(generator.isPlaying)
    }

    func testStopPlayback() {
        generator.duration = 60.0
        generator.mockStart()
        generator.stop()

        XCTAssertFalse(generator.isPlaying)
        XCTAssertEqual(generator.currentTime, 0)
    }

    func testPausePlayback() {
        generator.duration = 60.0
        generator.mockStart()
        generator.pause()

        XCTAssertFalse(generator.isPlaying)
        // Current time should be preserved when pausing
        XCTAssertGreaterThanOrEqual(generator.currentTime, 0)
    }

    func testResumePlayback() {
        generator.duration = 60.0
        generator.mockStart()
        generator.pause()

        let pausedTime = generator.currentTime
        generator.resume()

        XCTAssertTrue(generator.isPlaying)
        XCTAssertEqual(generator.currentTime, pausedTime)
    }

    // MARK: - Buffer Generation Tests

    func testGenerateSineWaveBuffer() {
        let frequency = 440.0 // A4 note
        let volume: Float = 0.5

        let buffer = generator.generateSineWaveBuffer(frequency: frequency, volume: volume)

        XCTAssertNotNil(buffer)
        XCTAssertEqual(buffer?.frameLength, AppConstants.Audio.bufferSize)
        XCTAssertEqual(buffer?.format.sampleRate, AppConstants.Audio.sampleRate)
    }

    func testGenerateBufferWithDifferentFrequencies() {
        let frequencies: [Double] = [100.0, 200.0, 440.0, 1000.0]

        for frequency in frequencies {
            let buffer = generator.generateSineWaveBuffer(frequency: frequency, volume: 0.5)
            XCTAssertNotNil(buffer, "Buffer generation failed for frequency \(frequency) Hz")
        }
    }
}

// MARK: - Mock Audio Generator

/// Mock implementation for testing base audio generator functionality
class MockAudioGenerator: BaseAudioGenerator {

    func mockStart() {
        isPlaying = true
        startTimer()
    }

    override func updateVolume() {
        // Mock implementation - no actual audio nodes to update
    }
}
