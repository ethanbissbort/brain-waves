//
//  SettingsManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class SettingsManager: ObservableObject, SettingsManagerProtocol {
    static let shared = SettingsManager()

    @Published var volume: Float {
        didSet {
            saveVolume()
        }
    }

    private let userDefaults = UserDefaults.standard

    private init() {
        // Load saved volume or use default
        // Use object(forKey:) to properly distinguish between "not set" and "set to 0"
        if let savedVolume = userDefaults.object(forKey: AppConstants.Storage.volumePreferenceKey) as? Float {
            self.volume = savedVolume
        } else {
            self.volume = AppConstants.Audio.defaultVolume
        }
    }

    private func saveVolume() {
        userDefaults.set(volume, forKey: AppConstants.Storage.volumePreferenceKey)
    }

    func resetToDefaults() {
        volume = AppConstants.Audio.defaultVolume
    }
}
