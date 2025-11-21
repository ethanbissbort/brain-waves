//
//  ContentView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioSessionManager = AudioSessionManager.shared
    @StateObject private var presetCoordinator = PresetCoordinator.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BinauralBeatsView()
                .tabItem {
                    Label("Binaural Beats", systemImage: "waveform.path")
                }
                .tag(0)

            IsochronicTonesView()
                .tabItem {
                    Label("Isochronic Tones", systemImage: "waveform")
                }
                .tag(1)

            MultiLayerView()
                .tabItem {
                    Label("Multi-Layer", systemImage: "square.stack.3d.up.fill")
                }
                .tag(2)

            PresetsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Presets", systemImage: "bookmark.fill")
                }
                .tag(3)

            PlaylistView()
                .tabItem {
                    Label("Playlists", systemImage: "list.bullet")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .environmentObject(presetCoordinator)
        .onChange(of: presetCoordinator.shouldNavigateToBinaural) { shouldNavigate in
            if shouldNavigate {
                selectedTab = 0
            }
        }
        .onChange(of: presetCoordinator.shouldNavigateToIsochronic) { shouldNavigate in
            if shouldNavigate {
                selectedTab = 1
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
