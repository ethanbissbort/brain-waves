//
//  WaveformVisualizer.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

enum VisualizerStyle: String, CaseIterable {
    case waveform = "Waveform"
    case bars = "Bars"
    case circle = "Circle"
    case particles = "Particles"

    var icon: String {
        switch self {
        case .waveform:
            return "waveform"
        case .bars:
            return "chart.bar.fill"
        case .circle:
            return "circle.hexagongrid.circle.fill"
        case .particles:
            return "sparkles"
        }
    }
}

struct WaveformVisualizer: View {
    let frequency: Double
    let isPlaying: Bool
    let waveformType: AppConstants.WaveformType
    @State private var visualizerStyle: VisualizerStyle = .waveform
    @State private var phase: Double = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 12) {
            // Style selector
            HStack {
                Text("Visualizer")
                    .font(.headline)
                Spacer()
                Picker("Style", selection: $visualizerStyle) {
                    ForEach(VisualizerStyle.allCases, id: \.self) { style in
                        Label(style.rawValue, systemImage: style.icon)
                            .tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
            }

            // Visualizer display
            ZStack {
                Color(.systemGray6)
                    .cornerRadius(12)

                if isPlaying {
                    switch visualizerStyle {
                    case .waveform:
                        WaveformView(
                            frequency: frequency,
                            waveformType: waveformType,
                            phase: phase
                        )
                    case .bars:
                        BarsVisualizerView(
                            frequency: frequency,
                            phase: phase
                        )
                    case .circle:
                        CircleVisualizerView(
                            frequency: frequency,
                            phase: phase
                        )
                    case .particles:
                        ParticlesVisualizerView(
                            frequency: frequency,
                            phase: phase
                        )
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "waveform.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Start playback to see visualization")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
        .onChange(of: isPlaying) { playing in
            if playing {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }

    private func startAnimation() {
        stopAnimation() // Clean up any existing timer

        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            // Update phase based on frequency
            phase += frequency * 2 * .pi / 60.0
            if phase > 2 * .pi * 10 {
                phase = 0
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
        phase = 0
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    let frequency: Double
    let waveformType: AppConstants.WaveformType
    let phase: Double

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midY = height / 2

                let points = 200
                let cycles = 3.0

                for i in 0..<points {
                    let x = CGFloat(i) / CGFloat(points) * width
                    let normalizedX = Double(i) / Double(points) * cycles
                    let angle = normalizedX * 2 * .pi + phase

                    let amplitude = calculateAmplitude(for: angle)
                    let y = midY - CGFloat(amplitude) * (height / 2) * 0.8

                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(waveformColor, lineWidth: 2)
            .animation(.linear(duration: 0.016), value: phase)
        }
        .padding()
    }

    private func calculateAmplitude(for angle: Double) -> Double {
        switch waveformType {
        case .sine:
            return sin(angle)
        case .square:
            return sin(angle) >= 0 ? 1.0 : -1.0
        case .triangle:
            let normalized = (angle / (2 * .pi)).truncatingRemainder(dividingBy: 1.0)
            if normalized < 0.25 {
                return normalized * 4
            } else if normalized < 0.75 {
                return 1.0 - (normalized - 0.25) * 4
            } else {
                return -1.0 + (normalized - 0.75) * 4
            }
        case .sawtooth:
            return (angle / .pi).truncatingRemainder(dividingBy: 2.0) - 1.0
        case .whiteNoise, .pinkNoise, .brownNoise:
            return Double.random(in: -0.5...0.5)
        }
    }

    private var waveformColor: Color {
        switch waveformType {
        case .sine:
            return .blue
        case .square:
            return .purple
        case .triangle:
            return .green
        case .sawtooth:
            return .orange
        case .whiteNoise:
            return .gray
        case .pinkNoise:
            return .pink
        case .brownNoise:
            return .brown
        }
    }
}

// MARK: - Bars Visualizer View

struct BarsVisualizerView: View {
    let frequency: Double
    let phase: Double

    private let barCount = 20

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: barHeight(for: index, maxHeight: geometry.size.height))
                }
            }
            .padding()
        }
    }

    private func barHeight(for index: Int, maxHeight: CGFloat) -> CGFloat {
        let normalizedIndex = Double(index) / Double(barCount)
        let offset = normalizedIndex * 2 * .pi
        let amplitude = abs(sin(phase + offset))

        // Modulate by frequency (higher frequency = more variation)
        let frequencyModulation = 1.0 + (frequency / 50.0) * sin(phase * 2 + offset)
        let clampedModulation = max(0.2, min(1.0, frequencyModulation))

        return CGFloat(amplitude * clampedModulation) * maxHeight * 0.8
    }
}

// MARK: - Circle Visualizer View

struct CircleVisualizerView: View {
    let frequency: Double
    let phase: Double

    private let ringCount = 8

    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let maxRadius = min(centerX, centerY) * 0.9

            ZStack {
                ForEach(0..<ringCount, id: \.self) { index in
                    let normalizedIndex = Double(index) / Double(ringCount)
                    let radius = maxRadius * (0.3 + normalizedIndex * 0.7)
                    let offset = normalizedIndex * 2 * .pi
                    let amplitude = abs(sin(phase + offset))

                    Circle()
                        .stroke(
                            ringColor(for: index),
                            lineWidth: CGFloat(2 + amplitude * 4)
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .opacity(0.3 + amplitude * 0.7)
                }

                // Center pulse
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.6), .clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(1.0 + abs(sin(phase)) * 0.3)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func ringColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .purple, .pink, .red, .orange, .yellow, .green, .cyan]
        return colors[index % colors.count]
    }
}

// MARK: - Particles Visualizer View

struct ParticlesVisualizerView: View {
    let frequency: Double
    let phase: Double

    private let particleCount = 30

    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2

            ZStack {
                ForEach(0..<particleCount, id: \.self) { index in
                    let angle = Double(index) / Double(particleCount) * 2 * .pi
                    let offset = sin(phase + angle * 3) * 0.5 + 0.5
                    let distance = 50.0 + offset * 100.0

                    let x = centerX + CGFloat(cos(angle + phase * 0.5) * distance)
                    let y = centerY + CGFloat(sin(angle + phase * 0.5) * distance)

                    Circle()
                        .fill(particleColor(for: offset))
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                        .blur(radius: 1)
                }
            }
        }
    }

    private func particleColor(for offset: Double) -> Color {
        Color(
            hue: offset,
            saturation: 0.8,
            brightness: 0.9
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        WaveformVisualizer(
            frequency: 10.0,
            isPlaying: true,
            waveformType: .sine
        )

        WaveformVisualizer(
            frequency: 20.0,
            isPlaying: true,
            waveformType: .square
        )
    }
    .padding()
}
