//
//  BinauralBeatsGenerator.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import AVFoundation
import Combine

class BinauralBeatsGenerator: BaseAudioGenerator, AudioGenerator {
    private var leftPlayerNode: AVAudioPlayerNode?
    private var rightPlayerNode: AVAudioPlayerNode?
    private var mixer: AVAudioMixerNode?

    private var baseFrequency: Double = AppConstants.Audio.Frequency.defaultBase
    private var beatFrequency: Double = AppConstants.Audio.Frequency.defaultBeat

    override func updateVolume() {
        leftPlayerNode?.volume = volume
        rightPlayerNode?.volume = volume
    }

    override func setupAudioEngine() {
        super.setupAudioEngine()

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

            // Set initial volume
            leftPlayerNode?.volume = volume
            rightPlayerNode?.volume = volume

            leftPlayerNode?.play()
            rightPlayerNode?.play()

            isPlaying = true
            startTime = Date().addingTimeInterval(-pausedTime)

            startTimer()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func start() {
        start(
            baseFrequency: baseFrequency,
            beatFrequency: beatFrequency,
            duration: duration
        )
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

    override func stop() {
        leftPlayerNode?.stop()
        rightPlayerNode?.stop()
        super.stop()
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
}
