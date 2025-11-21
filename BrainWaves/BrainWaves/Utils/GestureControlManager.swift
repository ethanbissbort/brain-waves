//
//  GestureControlManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI
import Combine

// MARK: - Gesture Settings

struct GestureSettings: Codable {
    var isEnabled: Bool = true
    var swipeEnabled: Bool = true
    var pinchEnabled: Bool = true
    var doubleTapEnabled: Bool = true

    var swipeSensitivity: Double = 1.0 // 0.5 to 2.0
    var pinchSensitivity: Double = 1.0 // 0.5 to 2.0

    var swipeFrequencyStep: Double = 0.5 // Hz per swipe
    var volumeStepPercentage: Float = 0.05 // 5% per gesture
}

// MARK: - Gesture Control Manager

class GestureControlManager: ObservableObject {
    static let shared = GestureControlManager()

    @Published var settings: GestureSettings {
        didSet {
            saveSettings()
        }
    }

    @Published var lastGestureDescription: String = ""
    @Published var showGestureFeedback: Bool = false

    private let settingsKey = "GestureSettings"

    init() {
        self.settings = GestureControlManager.loadSettings()
    }

    // MARK: - Settings Persistence

    private static func loadSettings() -> GestureSettings {
        guard let data = UserDefaults.standard.data(forKey: "GestureSettings"),
              let settings = try? JSONDecoder().decode(GestureSettings.self, from: data) else {
            return GestureSettings()
        }
        return settings
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    // MARK: - Gesture Feedback

    func showFeedback(_ description: String) {
        lastGestureDescription = description
        showGestureFeedback = true

        HapticManager.shared.playSelection()

        // Auto-hide after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.showGestureFeedback = false
            }
        }
    }

    // MARK: - Frequency Adjustment

    func adjustFrequency(
        _ currentFrequency: Double,
        direction: SwipeDirection,
        range: ClosedRange<Double>,
        step: Double? = nil
    ) -> Double {
        guard settings.swipeEnabled else { return currentFrequency }

        let effectiveStep = (step ?? settings.swipeFrequencyStep) * settings.swipeSensitivity

        let newFrequency: Double
        switch direction {
        case .up, .right:
            newFrequency = min(currentFrequency + effectiveStep, range.upperBound)
        case .down, .left:
            newFrequency = max(currentFrequency - effectiveStep, range.lowerBound)
        }

        let change = newFrequency - currentFrequency
        if abs(change) > 0.01 {
            showFeedback(String(format: "Frequency: %.1f Hz (%+.1f)", newFrequency, change))
        }

        return newFrequency
    }

    // MARK: - Volume Adjustment

    func adjustVolume(
        _ currentVolume: Float,
        scale: CGFloat,
        previousScale: CGFloat
    ) -> Float {
        guard settings.pinchEnabled else { return currentVolume }

        let delta = Float(scale - previousScale) * Float(settings.pinchSensitivity) * 0.5
        let newVolume = max(0.0, min(1.0, currentVolume + delta))

        if abs(newVolume - currentVolume) > 0.01 {
            showFeedback(String(format: "Volume: %d%%", Int(newVolume * 100)))
        }

        return newVolume
    }
}

// MARK: - Swipe Direction

enum SwipeDirection {
    case up
    case down
    case left
    case right
}

// MARK: - Frequency Swipe Gesture Modifier

struct FrequencySwipeGesture: ViewModifier {
    @Binding var frequency: Double
    let range: ClosedRange<Double>
    let step: Double?
    let isEnabled: Bool

    @StateObject private var gestureManager = GestureControlManager.shared
    @State private var dragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        guard isEnabled && gestureManager.settings.swipeEnabled else { return }

                        // Vertical swipe for frequency
                        let verticalDrag = value.translation.height

                        if abs(verticalDrag) > abs(value.translation.width) {
                            // Determine direction based on cumulative drag
                            let threshold: CGFloat = 30

                            if verticalDrag < -threshold && dragOffset >= 0 {
                                // Swipe up
                                frequency = gestureManager.adjustFrequency(
                                    frequency,
                                    direction: .up,
                                    range: range,
                                    step: step
                                )
                                dragOffset = verticalDrag
                            } else if verticalDrag > threshold && dragOffset <= 0 {
                                // Swipe down
                                frequency = gestureManager.adjustFrequency(
                                    frequency,
                                    direction: .down,
                                    range: range,
                                    step: step
                                )
                                dragOffset = verticalDrag
                            }
                        }
                    }
                    .onEnded { _ in
                        dragOffset = 0
                    }
            )
    }
}

// MARK: - Volume Pinch Gesture Modifier

struct VolumePinchGesture: ViewModifier {
    @Binding var volume: Float
    let onVolumeChange: (Float) -> Void
    let isEnabled: Bool

    @StateObject private var gestureManager = GestureControlManager.shared
    @State private var previousScale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .gesture(
                MagnificationGesture()
                    .onChanged { scale in
                        guard isEnabled && gestureManager.settings.pinchEnabled else { return }

                        let newVolume = gestureManager.adjustVolume(
                            volume,
                            scale: scale,
                            previousScale: previousScale
                        )

                        if abs(newVolume - volume) > 0.01 {
                            volume = newVolume
                            onVolumeChange(newVolume)
                            previousScale = scale
                        }
                    }
                    .onEnded { _ in
                        previousScale = 1.0
                    }
            )
    }
}

// MARK: - Double-Tap Favorite Gesture Modifier

struct DoubleTapFavoriteGesture: ViewModifier {
    let onDoubleTap: () -> Void
    let isEnabled: Bool

    @StateObject private var gestureManager = GestureControlManager.shared

    func body(content: Content) -> some View {
        content
            .onTapGesture(count: 2) {
                guard isEnabled && gestureManager.settings.doubleTapEnabled else { return }

                HapticManager.shared.playSuccess()
                gestureManager.showFeedback("Added to favorites")
                onDoubleTap()
            }
    }
}

// MARK: - View Extensions

extension View {
    func frequencySwipeGesture(
        frequency: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double? = nil,
        isEnabled: Bool = true
    ) -> some View {
        modifier(FrequencySwipeGesture(
            frequency: frequency,
            range: range,
            step: step,
            isEnabled: isEnabled
        ))
    }

    func volumePinchGesture(
        volume: Binding<Float>,
        onVolumeChange: @escaping (Float) -> Void,
        isEnabled: Bool = true
    ) -> some View {
        modifier(VolumePinchGesture(
            volume: volume,
            onVolumeChange: onVolumeChange,
            isEnabled: isEnabled
        ))
    }

    func doubleTapFavorite(
        onDoubleTap: @escaping () -> Void,
        isEnabled: Bool = true
    ) -> some View {
        modifier(DoubleTapFavoriteGesture(
            onDoubleTap: onDoubleTap,
            isEnabled: isEnabled
        ))
    }
}

// MARK: - Gesture Feedback View

struct GestureFeedbackView: View {
    @ObservedObject var gestureManager = GestureControlManager.shared

    var body: some View {
        if gestureManager.showGestureFeedback {
            VStack {
                Spacer()

                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(gestureManager.lastGestureDescription)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                        .shadow(radius: 10)
                )
                .padding(.bottom, 100)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.3), value: gestureManager.showGestureFeedback)
        }
    }
}

// MARK: - Gesture Settings View

struct GestureSettingsView: View {
    @ObservedObject var gestureManager = GestureControlManager.shared

    var body: some View {
        Form {
            Section(header: Text("Enable Gestures")) {
                Toggle("Gesture Controls", isOn: $gestureManager.settings.isEnabled)

                if gestureManager.settings.isEnabled {
                    Toggle("Swipe to Adjust Frequency", isOn: $gestureManager.settings.swipeEnabled)
                    Toggle("Pinch to Adjust Volume", isOn: $gestureManager.settings.pinchEnabled)
                    Toggle("Double-Tap for Favorites", isOn: $gestureManager.settings.doubleTapEnabled)
                }
            }

            if gestureManager.settings.isEnabled {
                Section(header: Text("Sensitivity")) {
                    if gestureManager.settings.swipeEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Swipe Sensitivity")
                                Spacer()
                                Text(String(format: "%.1fx", gestureManager.settings.swipeSensitivity))
                                    .foregroundColor(.secondary)
                            }
                            Slider(
                                value: $gestureManager.settings.swipeSensitivity,
                                in: 0.5...2.0,
                                step: 0.1
                            )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Frequency Step")
                                Spacer()
                                Text(String(format: "%.1f Hz", gestureManager.settings.swipeFrequencyStep))
                                    .foregroundColor(.secondary)
                            }
                            Slider(
                                value: $gestureManager.settings.swipeFrequencyStep,
                                in: 0.1...5.0,
                                step: 0.1
                            )
                        }
                    }

                    if gestureManager.settings.pinchEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Pinch Sensitivity")
                                Spacer()
                                Text(String(format: "%.1fx", gestureManager.settings.pinchSensitivity))
                                    .foregroundColor(.secondary)
                            }
                            Slider(
                                value: $gestureManager.settings.pinchSensitivity,
                                in: 0.5...2.0,
                                step: 0.1
                            )
                        }
                    }
                }

                Section(header: Text("Gesture Guide")) {
                    GestureGuideRow(
                        icon: "arrow.up.arrow.down",
                        title: "Swipe Up/Down",
                        description: "Increase or decrease frequency"
                    )

                    GestureGuideRow(
                        icon: "arrow.up.left.and.arrow.down.right",
                        title: "Pinch In/Out",
                        description: "Decrease or increase volume"
                    )

                    GestureGuideRow(
                        icon: "hand.tap.fill",
                        title: "Double-Tap",
                        description: "Add current settings to favorites"
                    )
                }
            }
        }
        .navigationTitle("Gesture Controls")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GestureGuideRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    GestureSettingsView()
}
