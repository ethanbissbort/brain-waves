//
//  BaseGeneratorViewModelTests.swift
//  BrainWavesTests
//
//  Unit tests for base generator view model
//

import XCTest
import Combine
@testable import BrainWaves

final class BaseGeneratorViewModelTests: XCTestCase {

    var viewModel: TestGeneratorViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = TestGeneratorViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertEqual(viewModel.duration, AppConstants.Timer.defaultDuration)
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentTime, 0)
        XCTAssertFalse(viewModel.showingSavePreset)
        XCTAssertEqual(viewModel.presetName, "")
    }

    // MARK: - Duration Tests

    func testSetDuration() {
        let newDuration: TimeInterval = 900.0 // 15 minutes
        viewModel.setDuration(newDuration)

        XCTAssertEqual(viewModel.duration, newDuration)
    }

    func testDurationPresets() {
        XCTAssertFalse(viewModel.durationPresets.isEmpty)
        XCTAssertTrue(viewModel.durationPresets.contains(300.0)) // 5 min
        XCTAssertTrue(viewModel.durationPresets.contains(600.0)) // 10 min
        XCTAssertTrue(viewModel.durationPresets.contains(900.0)) // 15 min
    }

    // MARK: - Computed Properties Tests

    func testRemainingTime() {
        viewModel.setDuration(600.0)
        viewModel.currentTime = 150.0

        let remaining = viewModel.remainingTime
        XCTAssertEqual(remaining, 450.0)
    }

    func testRemainingTimeNeverNegative() {
        viewModel.setDuration(600.0)
        viewModel.currentTime = 700.0 // More than duration

        let remaining = viewModel.remainingTime
        XCTAssertGreaterThanOrEqual(remaining, 0)
    }

    func testProgress() {
        viewModel.setDuration(600.0)
        viewModel.currentTime = 300.0

        let progress = viewModel.progress
        XCTAssertEqual(progress, 0.5, accuracy: 0.01)
    }

    func testProgressNeverExceedsOne() {
        viewModel.setDuration(600.0)
        viewModel.currentTime = 700.0 // More than duration

        let progress = viewModel.progress
        XCTAssertLessThanOrEqual(progress, 1.0)
    }

    // MARK: - Time Formatting Tests

    func testFormatTime() {
        // Test various durations
        XCTAssertEqual(viewModel.formatTime(0), "0:00")
        XCTAssertEqual(viewModel.formatTime(59), "0:59")
        XCTAssertEqual(viewModel.formatTime(60), "1:00")
        XCTAssertEqual(viewModel.formatTime(61), "1:01")
        XCTAssertEqual(viewModel.formatTime(600), "10:00")
        XCTAssertEqual(viewModel.formatTime(3599), "59:59")
        XCTAssertEqual(viewModel.formatTime(3600), "1:00:00")
        XCTAssertEqual(viewModel.formatTime(3661), "1:01:01")
    }

    // MARK: - PresetStore Access Tests

    func testPresetStoreAccess() {
        XCTAssertNotNil(viewModel.presetStore)
        XCTAssertTrue(viewModel.presetStore === PresetStore.shared)
    }
}

// MARK: - Test View Model

/// Concrete implementation of BaseGeneratorViewModel for testing
class TestGeneratorViewModel: BaseGeneratorViewModel {
    // No additional implementation needed for base class testing
}
