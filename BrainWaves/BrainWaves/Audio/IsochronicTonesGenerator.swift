//
//  IsochronicTonesGenerator.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import AVFoundation
import Combine

class IsochronicTonesGenerator: BaseAudioGenerator, AudioGenerator {
    private var playerNode: AVAudioPlayerNode?
    private var mixer: AVAudioMixerNode?

    private var carrierFrequency: Double = AppConstants.Audio.Frequency.defaultCarrier
    private var pulseFrequency: Double = AppConstants.Audio.Frequency.defaultBeat

    override func updateVolume() {
        playerNode?.volume = volume
    }

    override func setupAudioEngine() {
        super.setupAudioEngine()

        playerNode = AVAudioPlayerNode()
        mixer = audioEngine?.mainMixerNode

        guard let engine = audioEngine,
              let player = playerNode,
              let mixer = mixer else {
            return
        }

        engine.attach(player)

        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        )

        guard let audioFormat = format else { return }

        engine.connect(player, to: mixer, format: audioFormat)
        engine.prepare()
    }

    func start(carrierFrequency: Double, pulseFrequency: Double, duration: TimeInterval) {
        guard !isPlaying else { return }

        self.carrierFrequency = carrierFrequency
        self.pulseFrequency = pulseFrequency
        self.duration = duration
        self.currentTime = pausedTime

        do {
            try audioEngine?.start()

            // Schedule initial buffers
            scheduleBuffers()

            playerNode?.play()

            isPlaying = true
            startTime = Date().addingTimeInterval(-pausedTime)

            // Start with fade in effect
            let savedVolume = volume
            fadeIn(to: savedVolume)

            startTimer()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func start() {
        start(
            carrierFrequency: carrierFrequency,
            pulseFrequency: pulseFrequency,
            duration: duration
        )
    }

    func pause() {
        guard isPlaying else { return }

        playerNode?.pause()
        audioEngine?.pause()

        isPlaying = false
        pausedTime = currentTime

        stopTimer()
    }

    override func stop() {
        playerNode?.stop()
        super.stop()
    }

    func resume() {
        guard !isPlaying else { return }
        start(carrierFrequency: carrierFrequency, pulseFrequency: pulseFrequency, duration: duration)
    }

    private func scheduleBuffers() {
        guard let player = playerNode else { return }

        let buffer = generateIsochronicToneBuffer()
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    private func generateIsochronicToneBuffer() -> AVAudioPCMBuffer {
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        )!

        let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: bufferSize
        )!

        buffer.frameLength = bufferSize

        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: 2)
        let leftSamples = UnsafeMutableBufferPointer<Float>(start: channels[0], count: Int(bufferSize))
        let rightSamples = UnsafeMutableBufferPointer<Float>(start: channels[1], count: Int(bufferSize))

        let carrierAngularFreq = 2.0 * Double.pi * carrierFrequency / sampleRate
        let pulseAngularFreq = 2.0 * Double.pi * pulseFrequency / sampleRate

        for i in 0..<Int(bufferSize) {
            // Generate carrier wave
            let carrierWave = sin(carrierAngularFreq * Double(i))

            // Generate pulse envelope (0 to 1)
            // Using a smoothed pulse for better sound quality
            let pulseEnvelope = (sin(pulseAngularFreq * Double(i)) + 1.0) / 2.0

            // Apply square-like pulse by thresholding
            let threshold = 0.5
            let pulse = pulseEnvelope > threshold ? 1.0 : 0.0

            // Combine carrier and pulse
            let sample = Float(carrierWave * pulse * Double(AppConstants.Audio.defaultVolume))

            // Same signal on both channels (mono)
            leftSamples[i] = sample
            rightSamples[i] = sample
        }

        return buffer
    }
}
