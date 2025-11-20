//
//  ContentView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioSessionManager = AudioSessionManager.shared

    var body: some View {
        TabView {
            BinauralBeatsView()
                .tabItem {
                    Label("Binaural Beats", systemImage: "waveform.path")
                }

            IsochronicTonesView()
                .tabItem {
                    Label("Isochronic Tones", systemImage: "waveform")
                }

            PresetsView()
                .tabItem {
                    Label("Presets", systemImage: "bookmark.fill")
                }

            PlaylistView()
                .tabItem {
                    Label("Playlists", systemImage: "list.bullet")
                }
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
