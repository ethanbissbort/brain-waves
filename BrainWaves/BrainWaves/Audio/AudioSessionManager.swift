//
//  AudioSessionManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import AVFoundation
import Combine

class AudioSessionManager: ObservableObject, AudioSessionManagerProtocol {
    static let shared = AudioSessionManager()

    @Published var isInterrupted = false
    private var cancellables = Set<AnyCancellable>()

    private init() {
        do {
            try configureAudioSession()
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
        setupNotifications()
    }

    // MARK: - AudioSessionManagerProtocol

    func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()

        // Configure for playback with mixing
        try audioSession.setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers]
        )

        // Activate the session
        try audioSession.setActive(true)

        print("Audio session configured successfully")
    }

    func handleInterruption(type: InterruptionType) {
        switch type {
        case .began:
            isInterrupted = true
            print("Audio interruption began")
        case .ended:
            isInterrupted = false
            print("Audio interruption ended")
            reactivateSession()
        }
    }

    // MARK: - Private Helpers

    private func setupNotifications() {
        // Handle audio interruptions (phone calls, alarms, etc.)
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                self?.handleInterruptionNotification(notification)
            }
            .store(in: &cancellables)

        // Handle route changes (headphones plugged/unplugged)
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] notification in
                self?.handleRouteChange(notification)
            }
            .store(in: &cancellables)
    }

    private func handleInterruptionNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            handleInterruption(type: .began)

        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    handleInterruption(type: .ended)
                }
            } else {
                handleInterruption(type: .ended)
            }

        @unknown default:
            break
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .newDeviceAvailable:
            print("New audio device available")

        case .oldDeviceUnavailable:
            print("Audio device removed")
            // Could pause playback here if headphones were removed

        default:
            break
        }
    }

    func reactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session reactivated")
        } catch {
            print("Failed to reactivate audio session: \(error.localizedDescription)")
        }
    }

    func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("Audio session deactivated")
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
