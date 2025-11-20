//
//  PlaybackControls.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct PlaybackControls: View {
    let isPlaying: Bool
    let onPlay: () -> Void
    let onPause: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 30) {
            Spacer()

            // Stop button
            Button(action: onStop) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 28))
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .clipShape(Circle())
            }

            // Play/Pause button
            Button(action: {
                if isPlaying {
                    onPause()
                } else {
                    onPlay()
                }
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .frame(width: 80, height: 80)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }

            Spacer()
        }
        .padding()
    }
}

struct PlaybackControls_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PlaybackControls(
                isPlaying: false,
                onPlay: {},
                onPause: {},
                onStop: {}
            )

            PlaybackControls(
                isPlaying: true,
                onPlay: {},
                onPause: {},
                onStop: {}
            )
        }
    }
}
