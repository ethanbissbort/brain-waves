//
//  BinauralBeatsGenerator.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import AVFoundation
import Combine

class BinauralBeatsGenerator: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var audioEngine: AVAudioEngine?
    private var leftPlayerNode: AVAudioPlayerNode?
    private var rightPlayerNode: AVAudioPlayerNode?
    private var mixer: AVAudioMixerNode?

    private var baseFrequency: Double = 200.0
    private var beatFrequency: Double = 10.0

    private let sampleRate: Double = 44100.0
    private let bufferSize: AVAudioFrameCount = 22050 // 0.5 seconds at 44.1kHz

    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0

    init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        leftPlayerNode = AVAudioPlayerNode()
        rightPlayerNode = AVAudioPlayerNode()
        mixer = audioEngine?.mainMixerNode

        guard let engine = audioEngine,
              let leftPlayer = leftPlayerNode,
              let rightPlayer = rightPlayerNode,
              let mixer = mixer else {
            return
        }

        engine.attach(leftPlayer)
        engine.attach(rightPlayer)

        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )

        guard let audioFormat = format else { return }

        // Connect left player to left channel
        engine.connect(leftPlayer, to: mixer, format: audioFormat)
        leftPlayer.pan = -1.0 // Full left

        // Connect right player to right channel
        engine.connect(rightPlayer, to: mixer, format: audioFormat)
        rightPlayer.pan = 1.0 // Full right

        engine.prepare()
    }

    func start(baseFrequency: Double, beatFrequency: Double, duration: TimeInterval) {
        guard !isPlaying else { return }

        self.baseFrequency = baseFrequency
        self.beatFrequency = beatFrequency
        self.duration = duration
        self.currentTime = pausedTime

        do {
            try audioEngine?.start()

            // Schedule initial buffers
            scheduleBuffers()

            leftPlayerNode?.play()
            rightPlayerNode?.play()

            isPlaying = true
            startTime = Date().addingTimeInterval(-pausedTime)

            startTimer()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func pause() {
        guard isPlaying else { return }

        leftPlayerNode?.pause()
        rightPlayerNode?.pause()
        audioEngine?.pause()

        isPlaying = false
        pausedTime = currentTime

        stopTimer()
    }

    func stop() {
        leftPlayerNode?.stop()
        rightPlayerNode?.stop()
        audioEngine?.stop()

        isPlaying = false
        currentTime = 0
        pausedTime = 0
        startTime = nil

        stopTimer()
    }

    func resume() {
        guard !isPlaying else { return }
        start(baseFrequency: baseFrequency, beatFrequency: beatFrequency, duration: duration)
    }

    private func scheduleBuffers() {
        guard let leftPlayer = leftPlayerNode,
              let rightPlayer = rightPlayerNode else {
            return
        }

        // Generate buffers for left and right channels
        let leftBuffer = generateSineWaveBuffer(frequency: baseFrequency)
        let rightBuffer = generateSineWaveBuffer(frequency: baseFrequency + beatFrequency)

        // Schedule buffers with looping
        leftPlayer.scheduleBuffer(leftBuffer, at: nil, options: .loops)
        rightPlayer.scheduleBuffer(rightBuffer, at: nil, options: .loops)
    }

    private func generateSineWaveBuffer(frequency: Double) -> AVAudioPCMBuffer {
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
            samples[i] = Float(sample) * 0.3 // Reduce volume to 30% to prevent clipping
        }

        return buffer
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateTime() {
        guard let startTime = startTime else { return }

        currentTime = Date().timeIntervalSince(startTime)

        if currentTime >= duration {
            stop()
        }
    }

    deinit {
        stop()
    }
}
