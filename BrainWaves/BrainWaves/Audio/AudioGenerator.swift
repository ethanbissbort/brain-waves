//
//  AudioGenerator.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import AVFoundation
import Combine

// MARK: - Audio Generator Protocol

/// Protocol defining the basic interface for audio generators
///
/// Audio generators are responsible for producing binaural beats or isochronic tones
/// and managing their playback state. Implementations should handle audio engine
/// configuration, buffer scheduling, and playback controls.
///
/// ## Topics
/// ### Playback State
/// - ``isPlaying``
/// - ``currentTime``
/// - ``duration``
///
/// ### Playback Controls
/// - ``start()``
/// - ``pause()``
/// - ``stop()``
/// - ``resume()``
protocol AudioGenerator: AnyObject {
    /// Indicates whether audio is currently playing
    var isPlaying: Bool { get }

    /// The current playback time in seconds
    var currentTime: TimeInterval { get }

    /// The total duration of the current session in seconds
    var duration: TimeInterval { get }

    /// Starts audio generation and playback
    func start()

    /// Pauses playback, preserving current time
    func pause()

    /// Stops playback and resets to beginning
    func stop()

    /// Resumes playback from paused state
    func resume()
}

// MARK: - Base Audio Generator

/// Base class for all audio generators providing common functionality
///
/// `BaseAudioGenerator` provides shared functionality for audio generation including:
/// - Audio engine management
/// - Volume control with fade effects
/// - Timer management for session duration tracking
/// - Sine wave buffer generation
///
/// Subclasses should override ``updateVolume()`` to apply volume changes to their
/// specific audio nodes.
///
/// ## Example
/// ```swift
/// class CustomGenerator: BaseAudioGenerator, AudioGenerator {
///     override func updateVolume() {
///         playerNode?.volume = volume
///     }
/// }
/// ```
///
/// ## Topics
/// ### Published Properties
/// - ``isPlaying``
/// - ``currentTime``
/// - ``duration``
/// - ``volume``
///
/// ### Volume Control
/// - ``setVolume(_:)``
/// - ``fadeIn(to:duration:)``
/// - ``fadeOut(duration:completion:)``
///
/// ### Buffer Generation
/// - ``generateSineWaveBuffer(frequency:volume:)``
///
/// ### Playback Control
/// - ``stop()``
class BaseAudioGenerator: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = AppConstants.Audio.defaultVolume

    var audioEngine: AVAudioEngine?
    let sampleRate: Double = AppConstants.Audio.sampleRate
    let bufferSize: AVAudioFrameCount = AppConstants.Audio.bufferSize

    var timer: Timer?
    var startTime: Date?
    var pausedTime: TimeInterval = 0

    // Fade effect properties
    private var fadeTimer: Timer?
    private var targetVolume: Float = 0
    private var fadeStartVolume: Float = 0
    private var fadeStartTime: Date?
    private var fadeDuration: TimeInterval = 0
    private var isFading = false

    init() {
        setupAudioEngine()
    }

    func setupAudioEngine() {
        audioEngine = AVAudioEngine()
    }

    /// Sets the volume level
    ///
    /// Volume is automatically clamped to the range [0.0, 1.0].
    /// This method stops any active fade effects and immediately applies the new volume.
    ///
    /// - Parameter newVolume: The desired volume level (0.0 to 1.0)
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        // Stop any active fade
        stopFade()
        updateVolume()
    }

    /// Updates volume for active audio nodes
    ///
    /// Subclasses should override this method to apply volume changes to their
    /// specific audio player nodes. The default implementation does nothing.
    ///
    /// ## Example
    /// ```swift
    /// override func updateVolume() {
    ///     leftPlayerNode?.volume = volume
    ///     rightPlayerNode?.volume = volume
    /// }
    /// ```
    func updateVolume() {
        // Default implementation - subclasses can override
    }

    // MARK: - Fade Effects

    /// Gradually increases volume from 0 to target level
    ///
    /// Creates a smooth fade-in effect using linear interpolation. This is typically
    /// called when starting playback to avoid abrupt audio onset.
    ///
    /// - Parameters:
    ///   - targetVolume: The final volume level (0.0 to 1.0)
    ///   - duration: Duration of the fade effect in seconds. Defaults to 2 seconds.
    func fadeIn(to targetVolume: Float, duration: TimeInterval = AppConstants.AudioEffects.fadeInDuration) {
        self.targetVolume = targetVolume
        self.fadeStartVolume = 0
        self.fadeDuration = duration
        self.volume = 0
        updateVolume()
        startFade()
    }

    /// Gradually decreases volume to 0
    ///
    /// Creates a smooth fade-out effect using linear interpolation. Optionally
    /// executes a completion handler when the fade completes.
    ///
    /// - Parameters:
    ///   - duration: Duration of the fade effect in seconds. Defaults to 2 seconds.
    ///   - completion: Optional closure to execute when fade completes
    func fadeOut(duration: TimeInterval = AppConstants.AudioEffects.fadeOutDuration, completion: (() -> Void)? = nil) {
        self.targetVolume = 0
        self.fadeStartVolume = volume
        self.fadeDuration = duration
        startFade {
            completion?()
        }
    }

    private func startFade(completion: (() -> Void)? = nil) {
        isFading = true
        fadeStartTime = Date()

        fadeTimer = Timer.scheduledTimer(withTimeInterval: AppConstants.AudioEffects.fadeSmoothness, repeats: true) { [weak self] _ in
            self?.updateFade(completion: completion)
        }
    }

    private func updateFade(completion: (() -> Void)? = nil) {
        guard let fadeStartTime = fadeStartTime, isFading else { return }

        let elapsed = Date().timeIntervalSince(fadeStartTime)
        let progress = min(elapsed / fadeDuration, 1.0)

        // Linear interpolation
        volume = fadeStartVolume + Float(progress) * (targetVolume - fadeStartVolume)
        updateVolume()

        if progress >= 1.0 {
            stopFade()
            completion?()
        }
    }

    private func stopFade() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        isFading = false
        fadeStartTime = nil
    }

    func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Timer.updateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateTime()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateTime() {
        guard let startTime = startTime else { return }

        currentTime = Date().timeIntervalSince(startTime)

        if currentTime >= duration {
            // Timer completed - trigger haptic feedback
            HapticManager.shared.playTimerComplete()
            stop()
        }
    }

    func resetPlayback() {
        isPlaying = false
        currentTime = 0
        pausedTime = 0
        startTime = nil
        stopTimer()
    }

    /// Generates an audio buffer containing a pure sine wave
    ///
    /// Creates a PCM buffer filled with samples of a sine wave at the specified frequency.
    /// This is the fundamental building block for binaural beats and isochronic tones.
    ///
    /// - Parameters:
    ///   - frequency: The frequency of the sine wave in Hz
    ///   - volume: The amplitude of the wave (0.0 to 1.0). Defaults to app default volume.
    /// - Returns: An `AVAudioPCMBuffer` containing the generated sine wave
    ///
    /// ## Implementation Details
    /// - Buffer size: Defined by ``AppConstants/Audio/bufferSize``
    /// - Sample rate: Defined by ``AppConstants/Audio/sampleRate`` (44.1 kHz)
    /// - Format: 32-bit float PCM, mono, non-interleaved
    func generateSineWaveBuffer(frequency: Double, volume: Float = AppConstants.Audio.defaultVolume) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )!

        let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: bufferSize
        )!

        buffer.frameLength = bufferSize

        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: 1)
        let samples = UnsafeMutableBufferPointer<Float>(start: channels[0], count: Int(bufferSize))

        let angularFrequency = 2.0 * Double.pi * frequency / sampleRate

        for i in 0..<Int(bufferSize) {
            let sample = sin(angularFrequency * Double(i))
            samples[i] = Float(sample) * volume
        }

        return buffer
    }

    func stop() {
        audioEngine?.stop()
        resetPlayback()
    }

    deinit {
        stop()
    }
}

// MARK: - Audio Generator Error

enum AudioGeneratorError: Error, LocalizedError {
    case engineStartFailed(Error)
    case invalidConfiguration
    case bufferGenerationFailed

    var errorDescription: String? {
        switch self {
        case .engineStartFailed(let error):
            return "Failed to start audio engine: \(error.localizedDescription)"
        case .invalidConfiguration:
            return "Invalid audio configuration"
        case .bufferGenerationFailed:
            return "Failed to generate audio buffer"
        }
    }
}
