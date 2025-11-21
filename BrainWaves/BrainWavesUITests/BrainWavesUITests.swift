//
//  BrainWavesUITests.swift
//  BrainWavesUITests
//
//  UI tests for critical user flows
//

import XCTest

final class BrainWavesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch Tests

    func testAppLaunches() throws {
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    func testAllTabsExist() throws {
        XCTAssertTrue(app.tabBars.buttons["Binaural"].exists)
        XCTAssertTrue(app.tabBars.buttons["Isochronic"].exists)
        XCTAssertTrue(app.tabBars.buttons["Presets"].exists)
        XCTAssertTrue(app.tabBars.buttons["Playlists"].exists)
    }

    // MARK: - Binaural Beats Flow Tests

    func testBinauralBeatsTabNavigation() throws {
        app.tabBars.buttons["Binaural"].tap()

        // Check that the binaural view is displayed
        XCTAssertTrue(app.staticTexts["Binaural Beats"].exists)
    }

    func testBinauralBeatsPlaybackControls() throws {
        app.tabBars.buttons["Binaural"].tap()

        // Check for playback controls
        let playButton = app.buttons["Play"]
        XCTAssertTrue(playButton.exists || app.buttons["▶"].exists)
    }

    func testBinauralBeatsVolumeControl() throws {
        app.tabBars.buttons["Binaural"].tap()

        // Check for volume control
        let volumeSlider = app.sliders.containing(.staticText, identifier: "Volume").firstMatch
        XCTAssertTrue(volumeSlider.exists || app.staticTexts["Volume"].exists)
    }

    // MARK: - Isochronic Tones Flow Tests

    func testIsochronicTonesTabNavigation() throws {
        app.tabBars.buttons["Isochronic"].tap()

        // Check that the isochronic view is displayed
        XCTAssertTrue(app.staticTexts["Isochronic Tones"].exists)
    }

    func testIsochronicTonesPlaybackControls() throws {
        app.tabBars.buttons["Isochronic"].tap()

        // Check for playback controls
        let playButton = app.buttons["Play"]
        XCTAssertTrue(playButton.exists || app.buttons["▶"].exists)
    }

    // MARK: - Presets Flow Tests

    func testPresetsTabNavigation() throws {
        app.tabBars.buttons["Presets"].tap()

        // Check that the presets view is displayed
        XCTAssertTrue(app.staticTexts["Presets"].exists || app.navigationBars["Presets"].exists)
    }

    func testPresetsListDisplaysDefaultPresets() throws {
        app.tabBars.buttons["Presets"].tap()

        // Check that default presets are displayed
        // Note: These might be in a List or ScrollView
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists || app.tables.firstMatch.exists)
    }

    func testPresetSelection() throws {
        app.tabBars.buttons["Presets"].tap()

        // Try to tap on a preset
        sleep(1) // Wait for view to load
        let firstPreset = app.buttons.matching(identifier: "preset-").firstMatch
        if firstPreset.exists {
            firstPreset.tap()
            // Should navigate to appropriate generator tab
            sleep(1)
        }
    }

    // MARK: - Playlists Flow Tests

    func testPlaylistsTabNavigation() throws {
        app.tabBars.buttons["Playlists"].tap()

        // Check that the playlists view is displayed
        XCTAssertTrue(app.staticTexts["Playlists"].exists || app.navigationBars["Playlists"].exists)
    }

    // MARK: - Frequency Adjustment Tests

    func testFrequencySliderInteraction() throws {
        app.tabBars.buttons["Binaural"].tap()

        // Find frequency sliders
        let sliders = app.sliders
        if sliders.count > 0 {
            let firstSlider = sliders.firstMatch
            XCTAssertTrue(firstSlider.exists)

            // Try to adjust the slider
            firstSlider.adjust(toNormalizedSliderPosition: 0.5)
        }
    }

    // MARK: - Timer Tests

    func testTimerControlExists() throws {
        app.tabBars.buttons["Binaural"].tap()

        // Check for timer/duration controls
        let durationText = app.staticTexts.containing(.staticText, identifier: "Duration").firstMatch
        XCTAssertTrue(durationText.exists || app.staticTexts.containing(.staticText, identifier: "10:00").firstMatch.exists)
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
