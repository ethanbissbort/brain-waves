//
//  BrainWavesApp.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

@main
struct BrainWavesApp: App {
    @UIApplicationDelegateAdaptor(QuickActionAppDelegate.self) var appDelegate

    init() {
        // Initialize audio session on app launch
        _ = AudioSessionManager.shared
        // Initialize quick actions
        _ = QuickActionManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
