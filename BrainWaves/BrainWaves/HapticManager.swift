//
//  HapticManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // Specific use cases
    func playButtonTap() {
        playImpact(style: .light)
    }

    func playStart() {
        playNotification(type: .success)
    }

    func playStop() {
        playImpact(style: .medium)
    }

    func playTimerComplete() {
        playNotification(type: .success)
        // Add a second impact for emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.playImpact(style: .heavy)
        }
    }

    func playPresetLoad() {
        playSelection()
    }
}
