//
//  BrainWavesApp.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

@main
struct BrainWavesApp: App {
    init() {
        // Initialize audio session on app launch
        _ = AudioSessionManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
