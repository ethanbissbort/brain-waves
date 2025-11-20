//
//  TimerControl.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct TimerControl: View {
    @Binding var duration: TimeInterval
    let durationPresets: [TimeInterval]
    let currentTime: TimeInterval
    let isPlaying: Bool

    @State private var showingCustomDuration = false
    @State private var customMinutes: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration")
                .font(.headline)

            // Preset buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(durationPresets, id: \.self) { preset in
                        Button(action: {
                            duration = preset
                        }) {
                            Text(formatDurationShort(preset))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(duration == preset ? .bold : .regular)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(duration == preset ? Color.blue : Color(.systemGray5))
                                .foregroundColor(duration == preset ? .white : .primary)
                                .cornerRadius(20)
                        }
                        .disabled(isPlaying)
                    }

                    Button(action: {
                        showingCustomDuration = true
                    }) {
                        Text("Custom")
                            .font(.system(.body, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(20)
                    }
                    .disabled(isPlaying)
                }
                .padding(.horizontal, 4)
            }

            // Progress and time display
            VStack(spacing: 8) {
                ProgressView(value: min(currentTime / duration, 1.0))
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.blue)

                HStack {
                    Text("Elapsed: \(formatTime(currentTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Remaining: \(formatTime(max(0, duration - currentTime)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingCustomDuration) {
            CustomDurationSheet(duration: $duration, isPresented: $showingCustomDuration)
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatDurationShort(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            return "\(hours)h"
        }
    }
}

struct CustomDurationSheet: View {
    @Binding var duration: TimeInterval
    @Binding var isPresented: Bool
    @State private var minutes: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter custom duration")
                    .font(.headline)

                HStack {
                    TextField("Minutes", text: $minutes)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                        .multilineTextAlignment(.center)

                    Text("minutes")
                        .foregroundColor(.secondary)
                }

                Button("Set Duration") {
                    if let mins = Int(minutes), mins > 0 {
                        duration = TimeInterval(mins * 60)
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(minutes.isEmpty || Int(minutes) == nil || Int(minutes)! <= 0)

                Spacer()
            }
            .padding()
            .navigationTitle("Custom Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct TimerControl_Previews: PreviewProvider {
    static var previews: some View {
        TimerControl(
            duration: .constant(600),
            durationPresets: [300, 600, 900, 1800, 3600],
            currentTime: 120,
            isPlaying: false
        )
        .padding()
    }
}
