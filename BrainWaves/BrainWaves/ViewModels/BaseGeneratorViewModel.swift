//
//  BaseGeneratorViewModel.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class BaseGeneratorViewModel: ObservableObject {
    @Published var duration: TimeInterval = AppConstants.Timer.defaultDuration
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var showingSavePreset = false
    @Published var presetName = ""

    let presetStore = PresetStore.shared
    let durationPresets = AppConstants.Timer.presetDurations

    var cancellables = Set<AnyCancellable>()

    func setDuration(_ duration: TimeInterval) {
        self.duration = duration
    }

    var remainingTime: TimeInterval {
        max(0, duration - currentTime)
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(currentTime / duration, 1.0)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
