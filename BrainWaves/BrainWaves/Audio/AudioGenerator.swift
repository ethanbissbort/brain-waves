//
//  AudioGenerator.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import AVFoundation
import Combine

// MARK: - Audio Generator Protocol

protocol AudioGenerator: AnyObject {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }

    func start()
    func pause()
    func stop()
    func resume()
}

// MARK: - Base Audio Generator

class BaseAudioGenerator: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    var audioEngine: AVAudioEngine?
    let sampleRate: Double = AppConstants.Audio.sampleRate
    let bufferSize: AVAudioFrameCount = AppConstants.Audio.bufferSize

    var timer: Timer?
    var startTime: Date?
    var pausedTime: TimeInterval = 0

    init() {
        setupAudioEngine()
    }

    func setupAudioEngine() {
        audioEngine = AVAudioEngine()
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
