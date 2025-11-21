//
//  PlaylistControlsView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct PlaylistControlsView: View {
    @Binding var playlist: Playlist
    @State private var showingCrossfadeSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundColor(.blue)
                Text("Playback Settings")
                    .font(.headline)
            }

            // Quick Controls
            HStack(spacing: 12) {
                // Shuffle Button
                Button(action: {
                    withAnimation {
                        playlist.shuffleEnabled.toggle()
                        HapticManager.shared.playSelection()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "shuffle")
                            .font(.body)
                        Text("Shuffle")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(playlist.shuffleEnabled ? Color.blue : Color(.systemGray5))
                    .foregroundColor(playlist.shuffleEnabled ? .white : .primary)
                    .cornerRadius(8)
                }

                // Repeat Button
                Button(action: {
                    cycleRepeatMode()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: playlist.repeatMode.icon)
                            .font(.body)
                        Text(repeatModeShortText)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(playlist.repeatMode != .off ? Color.green : Color(.systemGray5))
                    .foregroundColor(playlist.repeatMode != .off ? .white : .primary)
                    .cornerRadius(8)
                }
            }

            // Crossfade Setting
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "waveform.path")
                        .foregroundColor(.purple)
                    Text("Crossfade")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(String(format: "%.1f sec", playlist.crossfadeDuration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Slider(value: $playlist.crossfadeDuration, in: 0...10, step: 0.5)
                    .accentColor(.purple)

                Text("Smooth transition between presets")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)

            // Playback Info
            if playlist.items.count > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Playback Order")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(playbackDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // MARK: - Helpers

    private func cycleRepeatMode() {
        withAnimation {
            switch playlist.repeatMode {
            case .off:
                playlist.repeatMode = .all
            case .all:
                playlist.repeatMode = .one
            case .one:
                playlist.repeatMode = .off
            }
            HapticManager.shared.playSelection()
        }
    }

    private var repeatModeShortText: String {
        switch playlist.repeatMode {
        case .off:
            return "Repeat"
        case .one:
            return "One"
        case .all:
            return "All"
        }
    }

    private var playbackDescription: String {
        var description = ""

        if playlist.shuffleEnabled {
            description += "• Randomized playback order\n"
        } else {
            description += "• Sequential playback\n"
        }

        switch playlist.repeatMode {
        case .off:
            description += "• Stops after last preset"
        case .one:
            description += "• Repeats current preset indefinitely"
        case .all:
            description += "• Loops entire playlist"
        }

        if playlist.crossfadeDuration > 0 {
            description += "\n• \(String(format: "%.1f", playlist.crossfadeDuration))s crossfade between presets"
        }

        return description
    }
}

// MARK: - Playlist Template Selector

struct PlaylistTemplateSelector: View {
    @Binding var isPresented: Bool
    let onCreate: (Playlist) -> Void

    private let templates: [(name: String, description: String, icon: String, template: () -> Playlist)] = [
        (
            "Morning Energy",
            "Start your day with energizing beats",
            "sunrise.fill",
            Playlist.morningEnergyTemplate
        ),
        (
            "Deep Focus",
            "Extended concentration sessions",
            "target",
            Playlist.deepFocusTemplate
        ),
        (
            "Meditation Journey",
            "Progressive meditation experience",
            "brain.head.profile",
            Playlist.meditationJourneyTemplate
        ),
        (
            "Sleep Cycle",
            "Gradual descent into deep sleep",
            "moon.stars.fill",
            Playlist.sleepCycleTemplate
        )
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Choose a Template")) {
                    ForEach(templates, id: \.name) { template in
                        Button(action: {
                            createPlaylist(from: template.template())
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: template.icon)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(template.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                Section(header: Text("Template Features")) {
                    TemplateFeatureRow(
                        icon: "shuffle",
                        text: "Shuffle and repeat modes pre-configured"
                    )
                    TemplateFeatureRow(
                        icon: "waveform.path",
                        text: "Optimized crossfade durations"
                    )
                    TemplateFeatureRow(
                        icon: "list.bullet",
                        text: "Add your own presets to customize"
                    )
                }
            }
            .navigationTitle("Playlist Templates")
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

    private func createPlaylist(from template: Playlist) {
        onCreate(template)
        isPresented = false
        HapticManager.shared.playSuccess()
    }
}

struct TemplateFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        PlaylistControlsView(playlist: .constant(Playlist(
            name: "Test Playlist",
            items: [],
            shuffleEnabled: true,
            repeatMode: .all,
            crossfadeDuration: 5.0
        )))

        Spacer()
    }
    .padding()
}
