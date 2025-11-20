//
//  VolumeControl.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct VolumeControl: View {
    @Binding var volume: Float
    let onVolumeChange: (Float) -> Void
    @State private var isMuted = false
    @State private var volumeBeforeMute: Float = 0.3

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Volume")
                    .font(.headline)

                Spacer()

                Text("\(Int(volume * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                // Mute button
                Button(action: toggleMute) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : volumeIcon)
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(width: 30)
                }
                .buttonStyle(.plain)

                // Volume slider
                Slider(value: Binding(
                    get: { volume },
                    set: { newValue in
                        volume = newValue
                        isMuted = newValue == 0
                        onVolumeChange(newValue)
                    }
                ), in: 0...1)
                .accentColor(.blue)
                .disabled(false)

                // Volume percentage
                Text("\(Int(volume * 100))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 25)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppConstants.UI.cornerRadius)
    }

    private var volumeIcon: String {
        switch volume {
        case 0:
            return "speaker.slash.fill"
        case 0..<0.33:
            return "speaker.wave.1.fill"
        case 0.33..<0.66:
            return "speaker.wave.2.fill"
        default:
            return "speaker.wave.3.fill"
        }
    }

    private func toggleMute() {
        if isMuted {
            // Unmute: restore previous volume
            volume = volumeBeforeMute
            isMuted = false
            onVolumeChange(volume)
        } else {
            // Mute: save current volume and set to 0
            volumeBeforeMute = volume
            volume = 0
            isMuted = true
            onVolumeChange(0)
        }
    }
}

struct VolumeControl_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            VolumeControl(volume: .constant(0.3), onVolumeChange: { _ in })
            VolumeControl(volume: .constant(0.0), onVolumeChange: { _ in })
            VolumeControl(volume: .constant(1.0), onVolumeChange: { _ in })
        }
        .padding()
    }
}
