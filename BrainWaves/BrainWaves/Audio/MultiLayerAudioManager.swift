//
//  MultiLayerAudioManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import AVFoundation

// MARK: - Audio Layer Model

struct AudioLayer: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var layerType: AudioLayerType
    var volume: Float
    var isEnabled: Bool

    // For tone layers
    var frequency: Double?
    var waveformType: AppConstants.WaveformType?

    // For binaural beat layers
    var baseFrequency: Double?
    var beatFrequency: Double?

    // For ambient layers
    var ambientType: AmbientSoundType?

    init(
        id: UUID = UUID(),
        name: String,
        layerType: AudioLayerType,
        volume: Float = 0.5,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.layerType = layerType
        self.volume = volume
        self.isEnabled = isEnabled
    }

    // Convenience initializers
    static func binauralBeat(
        name: String,
        baseFrequency: Double,
        beatFrequency: Double,
        waveformType: AppConstants.WaveformType = .sine,
        volume: Float = 0.5
    ) -> AudioLayer {
        var layer = AudioLayer(name: name, layerType: .binauralBeat, volume: volume)
        layer.baseFrequency = baseFrequency
        layer.beatFrequency = beatFrequency
        layer.waveformType = waveformType
        return layer
    }

    static func tone(
        name: String,
        frequency: Double,
        waveformType: AppConstants.WaveformType = .sine,
        volume: Float = 0.5
    ) -> AudioLayer {
        var layer = AudioLayer(name: name, layerType: .tone, volume: volume)
        layer.frequency = frequency
        layer.waveformType = waveformType
        return layer
    }

    static func ambient(
        name: String,
        ambientType: AmbientSoundType,
        volume: Float = 0.3
    ) -> AudioLayer {
        var layer = AudioLayer(name: name, layerType: .ambient, volume: volume)
        layer.ambientType = ambientType
        return layer
    }
}

enum AudioLayerType: String, Codable, CaseIterable {
    case binauralBeat = "Binaural Beat"
    case tone = "Tone"
    case ambient = "Ambient Sound"

    var icon: String {
        switch self {
        case .binauralBeat:
            return "waveform.path.ecg"
        case .tone:
            return "waveform"
        case .ambient:
            return "speaker.wave.2.fill"
        }
    }
}

enum AmbientSoundType: String, Codable, CaseIterable {
    case whiteNoise = "White Noise"
    case pinkNoise = "Pink Noise"
    case brownNoise = "Brown Noise"
    case rain = "Rain"
    case ocean = "Ocean Waves"
    case forest = "Forest Ambience"
    case stream = "Stream"
    case wind = "Wind"

    var icon: String {
        switch self {
        case .whiteNoise:
            return "waveform.circle"
        case .pinkNoise:
            return "waveform.circle.fill"
        case .brownNoise:
            return "waveform.badge.minus"
        case .rain:
            return "cloud.rain.fill"
        case .ocean:
            return "water.waves"
        case .forest:
            return "leaf.fill"
        case .stream:
            return "drop.fill"
        case .wind:
            return "wind"
        }
    }

    var waveformType: AppConstants.WaveformType {
        switch self {
        case .whiteNoise:
            return .whiteNoise
        case .pinkNoise:
            return .pinkNoise
        case .brownNoise:
            return .brownNoise
        case .rain, .ocean, .forest, .stream, .wind:
            return .brownNoise // Use brown noise as base for nature sounds
        }
    }
}

// MARK: - Multi-Layer Audio Manager

class MultiLayerAudioManager: ObservableObject {
    @Published var layers: [AudioLayer] = []
    @Published var isPlaying = false
    @Published var masterVolume: Float = 1.0

    private var audioEngine: AVAudioEngine?
    private var playerNodes: [UUID: AVAudioPlayerNode] = [:]
    private var mixerNodes: [UUID: AVAudioMixerNode] = [:]

    private let sampleRate: Double = 44100
    private let bufferSize: AVAudioFrameCount = 1024

    init() {
        setupAudioEngine()
    }

    // MARK: - Audio Engine Setup

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
    }

    // MARK: - Layer Management

    func addLayer(_ layer: AudioLayer) {
        layers.append(layer)
    }

    func removeLayer(_ layer: AudioLayer) {
        layers.removeAll { $0.id == layer.id }
        stopLayerAudio(for: layer.id)
    }

    func updateLayer(_ layer: AudioLayer) {
        if let index = layers.firstIndex(where: { $0.id == layer.id }) {
            layers[index] = layer

            // Update audio if playing
            if isPlaying && layer.isEnabled {
                restartLayerAudio(for: layer.id)
            } else if isPlaying && !layer.isEnabled {
                stopLayerAudio(for: layer.id)
            }
        }
    }

    func toggleLayer(_ layer: AudioLayer) {
        var updatedLayer = layer
        updatedLayer.isEnabled.toggle()
        updateLayer(updatedLayer)
    }

    // MARK: - Playback Control

    func play() {
        guard let engine = audioEngine else { return }

        do {
            // Prepare audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)

            // Start all enabled layers
            for layer in layers where layer.isEnabled {
                startLayerAudio(for: layer)
            }

            // Start engine
            if !engine.isRunning {
                try engine.start()
            }

            isPlaying = true
        } catch {
            print("Error starting multi-layer audio: \(error)")
        }
    }

    func pause() {
        audioEngine?.pause()
        isPlaying = false
    }

    func stop() {
        audioEngine?.stop()

        // Clean up all player nodes
        for (id, _) in playerNodes {
            stopLayerAudio(for: id)
        }

        isPlaying = false
    }

    // MARK: - Layer Audio Management

    private func startLayerAudio(for layer: AudioLayer) {
        guard let engine = audioEngine else { return }

        // Create player node and mixer for this layer
        let playerNode = AVAudioPlayerNode()
        let mixerNode = AVAudioMixerNode()

        engine.attach(playerNode)
        engine.attach(mixerNode)

        // Connect player -> mixer -> main mixer
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        )!

        engine.connect(playerNode, to: mixerNode, format: format)
        engine.connect(mixerNode, to: engine.mainMixerNode, format: format)

        // Set volume
        mixerNode.outputVolume = layer.volume * masterVolume

        // Store nodes
        playerNodes[layer.id] = playerNode
        mixerNodes[layer.id] = mixerNode

        // Schedule buffers for this layer
        scheduleBuffers(for: layer, playerNode: playerNode, format: format)

        // Start playing
        playerNode.play()
    }

    private func stopLayerAudio(for layerId: UUID) {
        guard let playerNode = playerNodes[layerId],
              let mixerNode = mixerNodes[layerId],
              let engine = audioEngine else { return }

        playerNode.stop()
        engine.detach(playerNode)
        engine.detach(mixerNode)

        playerNodes.removeValue(forKey: layerId)
        mixerNodes.removeValue(forKey: layerId)
    }

    private func restartLayerAudio(for layerId: UUID) {
        stopLayerAudio(for: layerId)

        if let layer = layers.first(where: { $0.id == layerId }) {
            startLayerAudio(for: layer)
        }
    }

    private func scheduleBuffers(
        for layer: AudioLayer,
        playerNode: AVAudioPlayerNode,
        format: AVAudioFormat
    ) {
        // Generate audio buffer based on layer type
        let buffer = generateBuffer(for: layer, format: format)

        // Schedule buffer to loop
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    // MARK: - Audio Generation

    private func generateBuffer(for layer: AudioLayer, format: AVAudioFormat) -> AVAudioPCMBuffer {
        let frameCount = bufferSize * 100 // Large buffer for smooth looping

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            fatalError("Unable to create audio buffer")
        }

        buffer.frameLength = frameCount

        guard let leftChannel = buffer.floatChannelData?[0],
              let rightChannel = buffer.floatChannelData?[1] else {
            return buffer
        }

        switch layer.layerType {
        case .binauralBeat:
            generateBinauralBeat(
                leftChannel: leftChannel,
                rightChannel: rightChannel,
                frameCount: Int(frameCount),
                baseFrequency: layer.baseFrequency ?? 200,
                beatFrequency: layer.beatFrequency ?? 10,
                waveformType: layer.waveformType ?? .sine
            )

        case .tone:
            generateTone(
                leftChannel: leftChannel,
                rightChannel: rightChannel,
                frameCount: Int(frameCount),
                frequency: layer.frequency ?? 440,
                waveformType: layer.waveformType ?? .sine
            )

        case .ambient:
            generateAmbient(
                leftChannel: leftChannel,
                rightChannel: rightChannel,
                frameCount: Int(frameCount),
                ambientType: layer.ambientType ?? .whiteNoise
            )
        }

        return buffer
    }

    private func generateBinauralBeat(
        leftChannel: UnsafeMutablePointer<Float>,
        rightChannel: UnsafeMutablePointer<Float>,
        frameCount: Int,
        baseFrequency: Double,
        beatFrequency: Double,
        waveformType: AppConstants.WaveformType
    ) {
        let leftFreq = baseFrequency
        let rightFreq = baseFrequency + beatFrequency

        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            leftChannel[i] = generateSample(frequency: leftFreq, time: time, waveformType: waveformType)
            rightChannel[i] = generateSample(frequency: rightFreq, time: time, waveformType: waveformType)
        }
    }

    private func generateTone(
        leftChannel: UnsafeMutablePointer<Float>,
        rightChannel: UnsafeMutablePointer<Float>,
        frameCount: Int,
        frequency: Double,
        waveformType: AppConstants.WaveformType
    ) {
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let sample = generateSample(frequency: frequency, time: time, waveformType: waveformType)
            leftChannel[i] = sample
            rightChannel[i] = sample
        }
    }

    private func generateAmbient(
        leftChannel: UnsafeMutablePointer<Float>,
        rightChannel: UnsafeMutablePointer<Float>,
        frameCount: Int,
        ambientType: AmbientSoundType
    ) {
        let waveformType = ambientType.waveformType

        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let sample = generateNoiseSample(waveformType: waveformType)
            leftChannel[i] = sample
            rightChannel[i] = sample
        }
    }

    private func generateSample(frequency: Double, time: Double, waveformType: AppConstants.WaveformType) -> Float {
        let angle = 2.0 * .pi * frequency * time

        switch waveformType {
        case .sine:
            return Float(sin(angle))
        case .square:
            return sin(angle) >= 0 ? 1.0 : -1.0
        case .triangle:
            return Float(2.0 / .pi * asin(sin(angle)))
        case .sawtooth:
            return Float(2.0 * (frequency * time - floor(frequency * time + 0.5)))
        case .whiteNoise, .pinkNoise, .brownNoise:
            return generateNoiseSample(waveformType: waveformType)
        }
    }

    private var brownNoiseState: Float = 0

    private func generateNoiseSample(waveformType: AppConstants.WaveformType) -> Float {
        switch waveformType {
        case .whiteNoise:
            return Float.random(in: -1.0...1.0)
        case .pinkNoise:
            // Simplified pink noise approximation
            let white = Float.random(in: -1.0...1.0)
            return white * 0.5
        case .brownNoise:
            // Brown noise (random walk)
            let white = Float.random(in: -0.1...0.1)
            brownNoiseState += white
            brownNoiseState = max(-1.0, min(1.0, brownNoiseState)) // Clamp
            return brownNoiseState
        default:
            return 0
        }
    }

    // MARK: - Volume Control

    func setMasterVolume(_ volume: Float) {
        masterVolume = volume
        audioEngine?.mainMixerNode.outputVolume = volume

        // Update all layer volumes
        for layer in layers {
            if let mixerNode = mixerNodes[layer.id] {
                mixerNode.outputVolume = layer.volume * masterVolume
            }
        }
    }

    func setLayerVolume(_ layerId: UUID, volume: Float) {
        if let index = layers.firstIndex(where: { $0.id == layerId }) {
            layers[index].volume = volume

            if let mixerNode = mixerNodes[layerId] {
                mixerNode.outputVolume = volume * masterVolume
            }
        }
    }

    // MARK: - Preset Templates

    static func deepMeditationPreset() -> [AudioLayer] {
        return [
            .binauralBeat(
                name: "Theta Waves",
                baseFrequency: 200,
                beatFrequency: 6,
                waveformType: .sine,
                volume: 0.6
            ),
            .ambient(
                name: "Ocean Background",
                ambientType: .ocean,
                volume: 0.3
            )
        ]
    }

    static func focusPreset() -> [AudioLayer] {
        return [
            .binauralBeat(
                name: "Beta Waves",
                baseFrequency: 200,
                beatFrequency: 20,
                waveformType: .sine,
                volume: 0.7
            ),
            .ambient(
                name: "White Noise",
                ambientType: .whiteNoise,
                volume: 0.2
            )
        ]
    }

    static func sleepPreset() -> [AudioLayer] {
        return [
            .binauralBeat(
                name: "Delta Waves",
                baseFrequency: 200,
                beatFrequency: 2,
                waveformType: .sine,
                volume: 0.5
            ),
            .ambient(
                name: "Rain",
                ambientType: .rain,
                volume: 0.4
            ),
            .ambient(
                name: "Brown Noise",
                ambientType: .brownNoise,
                volume: 0.2
            )
        ]
    }
}
