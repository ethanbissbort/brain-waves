//
//  HapticManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import UIKit

class HapticManager: HapticManagerProtocol {
    static let shared = HapticManager()

    private init() {}

    // MARK: - HapticManagerProtocol

    func lightImpact() {
        playImpact(style: .light)
    }

    func mediumImpact() {
        playImpact(style: .medium)
    }

    func heavyImpact() {
        playImpact(style: .heavy)
    }

    func selectionChanged() {
        playSelection()
    }

    func success() {
        playNotification(type: .success)
    }

    func warning() {
        playNotification(type: .warning)
    }

    func error() {
        playNotification(type: .error)
    }

    // MARK: - Private Helpers

    private func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    private func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // MARK: - Legacy Methods (for backward compatibility)

    func playButtonTap() {
        lightImpact()
    }

    func playStart() {
        success()
    }

    func playStop() {
        mediumImpact()
    }

    func playTimerComplete() {
        success()
        // Add a second impact for emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.heavyImpact()
        }
    }

    func playPresetLoad() {
        selectionChanged()
    }
}
