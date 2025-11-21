//
//  SettingsManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var volume: Float {
        didSet {
            saveVolume()
        }
    }

    private let userDefaults = UserDefaults.standard

    private init() {
        // Load saved volume or use default
        self.volume = userDefaults.float(forKey: AppConstants.Storage.volumePreferenceKey)

        // If no saved volume (returns 0), use default
        if volume == 0 {
            volume = AppConstants.Audio.defaultVolume
        }
    }

    private func saveVolume() {
        userDefaults.set(volume, forKey: AppConstants.Storage.volumePreferenceKey)
    }

    func resetToDefaults() {
        volume = AppConstants.Audio.defaultVolume
    }
}
