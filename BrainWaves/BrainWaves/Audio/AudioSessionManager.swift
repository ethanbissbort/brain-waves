//
//  AudioSessionManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import AVFoundation
import Combine

class AudioSessionManager: ObservableObject {
    static let shared = AudioSessionManager()

    @Published var isInterrupted = false
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupAudioSession()
        setupNotifications()
    }

    private func setupAudioSession() {
        do {
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
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    private func setupNotifications() {
        // Handle audio interruptions (phone calls, alarms, etc.)
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                self?.handleInterruption(notification)
            }
            .store(in: &cancellables)

        // Handle route changes (headphones plugged/unplugged)
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] notification in
                self?.handleRouteChange(notification)
            }
            .store(in: &cancellables)
    }

    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Interruption began - audio playback is suspended
            isInterrupted = true
            print("Audio interruption began")

        case .ended:
            // Interruption ended - audio playback can resume
            isInterrupted = false

            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume playback if appropriate
                    print("Audio interruption ended - should resume")
                    reactivateSession()
                }
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
