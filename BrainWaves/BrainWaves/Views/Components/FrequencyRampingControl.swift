//
//  FrequencyRampingControl.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct FrequencyRampingControl: View {
    @Binding var config: FrequencyRampConfig
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: config.enabled ? "chart.line.uptrend.xyaxis" : "chart.xyaxis.line")
                    .foregroundColor(config.enabled ? .blue : .gray)
                Text("Frequency Ramping")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $config.enabled)
                    .labelsHidden()
                    .onChange(of: config.enabled) { _ in
                        HapticManager.shared.playSelection()
                    }
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                    HapticManager.shared.playSelection()
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            }

            if config.enabled && isExpanded {
                VStack(spacing: 16) {
                    // Ramp Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ramp Type")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Picker("Ramp Type", selection: $config.rampType) {
                            ForEach(AppConstants.RampType.allCases, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        Text(config.rampType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if config.rampType != .none {
                        // Start Frequency
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Start Frequency")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.1f Hz", config.startFrequency))
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Slider(value: $config.startFrequency, in: 0.5...100.0, step: 0.5)
                        }

                        // End Frequency
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("End Frequency")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.1f Hz", config.endFrequency))
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Slider(value: $config.endFrequency, in: 0.5...100.0, step: 0.5)
                        }

                        // Ramp Duration
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Ramp Duration")
                                    .font(.subheadline)
                                Spacer()
                                Text(formatDuration(config.rampDuration))
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Slider(value: $config.rampDuration, in: 60...3600, step: 60)
                        }

                        // Ramp Curve
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ramp Curve")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Picker("Ramp Curve", selection: $config.rampCurve) {
                                ForEach(AppConstants.RampCurve.allCases, id: \.self) { curve in
                                    Text(curve.rawValue).tag(curve)
                                }
                            }
                            .pickerStyle(.segmented)
                            Text(config.rampCurve.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency Path Preview")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            FrequencyRampPreview(config: config)
                                .frame(height: 60)
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

struct FrequencyRampPreview: View {
    let config: FrequencyRampConfig
    let samplePoints = 50

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                for i in 0..<samplePoints {
                    let progress = Double(i) / Double(samplePoints - 1)
                    let time = progress * config.rampDuration
                    let frequency = config.frequency(at: time, totalDuration: config.rampDuration)

                    // Normalize frequency to 0-1 range
                    let minFreq = min(config.startFrequency, config.endFrequency)
                    let maxFreq = max(config.startFrequency, config.endFrequency)
                    let range = maxFreq - minFreq
                    let normalizedFreq = range > 0 ? (frequency - minFreq) / range : 0.5

                    let x = CGFloat(progress) * width
                    let y = height - (CGFloat(normalizedFreq) * height)

                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}

#Preview {
    FrequencyRampingControl(config: .constant(FrequencyRampConfig(
        enabled: true,
        rampType: .ascending,
        startFrequency: 10.0,
        endFrequency: 2.0
    )))
    .padding()
}
