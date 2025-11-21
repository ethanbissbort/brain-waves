//
//  EnhancedTimerDisplay.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

enum TimerDisplayMode: String, CaseIterable {
    case compact = "Compact"
    case circular = "Circular"
    case large = "Large"

    var icon: String {
        switch self {
        case .compact:
            return "rectangle.compress.vertical"
        case .circular:
            return "circle"
        case .large:
            return "textformat.size.larger"
        }
    }
}

struct EnhancedTimerDisplay: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let isPlaying: Bool
    @State private var displayMode: TimerDisplayMode = .circular
    @State private var lastHapticMinute: Int = -1

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(currentTime / duration, 1.0)
    }

    var remainingTime: TimeInterval {
        max(0, duration - currentTime)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Mode selector
            HStack {
                Text("Timer Display")
                    .font(.headline)
                Spacer()
                Picker("Mode", selection: $displayMode) {
                    ForEach(TimerDisplayMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }

            // Display based on mode
            switch displayMode {
            case .compact:
                CompactTimerView(
                    currentTime: currentTime,
                    duration: duration,
                    remainingTime: remainingTime,
                    progress: progress,
                    isPlaying: isPlaying
                )
            case .circular:
                CircularTimerView(
                    currentTime: currentTime,
                    duration: duration,
                    remainingTime: remainingTime,
                    progress: progress,
                    isPlaying: isPlaying
                )
            case .large:
                LargeTimerView(
                    currentTime: currentTime,
                    duration: duration,
                    remainingTime: remainingTime,
                    progress: progress,
                    isPlaying: isPlaying
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onChange(of: currentTime) { _ in
            checkMilestones()
        }
    }

    private func checkMilestones() {
        guard isPlaying else { return }

        let currentMinute = Int(remainingTime / 60)

        // Haptic feedback at milestone minutes
        let milestones = [10, 5, 3, 2, 1]
        if milestones.contains(currentMinute) && currentMinute != lastHapticMinute {
            HapticManager.shared.playSelection()
            lastHapticMinute = currentMinute
        }
    }
}

// MARK: - Compact View

struct CompactTimerView: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let remainingTime: TimeInterval
    let progress: Double
    let isPlaying: Bool

    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(y: 1.5)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Elapsed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatTime(currentTime))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatTime(remainingTime))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(remainingTime < 60 ? .red : .primary)
                }
            }
        }
    }

    private var progressColor: Color {
        if progress < 0.25 { return .blue }
        if progress < 0.75 { return .green }
        if progress < 0.9 { return .orange }
        return .red
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Circular View

struct CircularTimerView: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let remainingTime: TimeInterval
    let progress: Double
    let isPlaying: Bool

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 20)
                .frame(width: 200, height: 200)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)

            // Center content
            VStack(spacing: 8) {
                Text(formatTime(remainingTime))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(remainingTime < 60 ? .red : .primary)

                Text("remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if isPlaying {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Playing")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
    }

    private var progressColor: Color {
        if progress < 0.25 { return .blue }
        if progress < 0.75 { return .green }
        if progress < 0.9 { return .orange }
        return .red
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Large View

struct LargeTimerView: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let remainingTime: TimeInterval
    let progress: Double
    let isPlaying: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Large countdown
            Text(formatTime(remainingTime))
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(remainingTime < 60 ? .red : progressColor)
                .minimumScaleFactor(0.5)

            Text("REMAINING")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .tracking(2)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray4))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 20)
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: 20)

            // Stats
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("ELAPSED")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatTime(currentTime))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.medium)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("DURATION")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatTime(duration))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.medium)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("PROGRESS")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(Int(progress * 100))%")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical)
    }

    private var progressColor: Color {
        if progress < 0.25 { return .blue }
        if progress < 0.75 { return .green }
        if progress < 0.9 { return .orange }
        return .red
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack(spacing: 20) {
        EnhancedTimerDisplay(
            currentTime: 420,
            duration: 600,
            isPlaying: true
        )
    }
    .padding()
}
