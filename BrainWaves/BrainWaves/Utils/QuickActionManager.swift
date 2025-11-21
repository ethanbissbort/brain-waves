//
//  QuickActionManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import UIKit
import SwiftUI

enum QuickActionType: String {
    case playLastSession = "com.brainwaves.playLastSession"
    case startMeditation = "com.brainwaves.startMeditation"
    case startFocus = "com.brainwaves.startFocus"
    case startSleep = "com.brainwaves.startSleep"

    var title: String {
        switch self {
        case .playLastSession:
            return "Resume Last Session"
        case .startMeditation:
            return "Start Meditation"
        case .startFocus:
            return "Start Focus Session"
        case .startSleep:
            return "Start Sleep Session"
        }
    }

    var icon: UIApplicationShortcutIcon {
        switch self {
        case .playLastSession:
            return UIApplicationShortcutIcon(systemImageName: "play.circle.fill")
        case .startMeditation:
            return UIApplicationShortcutIcon(systemImageName: "figure.mind.and.body")
        case .startFocus:
            return UIApplicationShortcutIcon(systemImageName: "target")
        case .startSleep:
            return UIApplicationShortcutIcon(systemImageName: "moon.stars.fill")
        }
    }
}

class QuickActionManager: ObservableObject {
    static let shared = QuickActionManager()

    @Published var pendingAction: QuickActionType?

    private init() {
        setupQuickActions()
    }

    // MARK: - Setup

    func setupQuickActions() {
        let playLastSession = UIApplicationShortcutItem(
            type: QuickActionType.playLastSession.rawValue,
            localizedTitle: QuickActionType.playLastSession.title,
            localizedSubtitle: "Continue where you left off",
            icon: QuickActionType.playLastSession.icon,
            userInfo: nil
        )

        let startMeditation = UIApplicationShortcutItem(
            type: QuickActionType.startMeditation.rawValue,
            localizedTitle: QuickActionType.startMeditation.title,
            localizedSubtitle: "10 Hz Alpha waves",
            icon: QuickActionType.startMeditation.icon,
            userInfo: nil
        )

        let startFocus = UIApplicationShortcutItem(
            type: QuickActionType.startFocus.rawValue,
            localizedTitle: QuickActionType.startFocus.title,
            localizedSubtitle: "20 Hz Beta waves",
            icon: QuickActionType.startFocus.icon,
            userInfo: nil
        )

        let startSleep = UIApplicationShortcutItem(
            type: QuickActionType.startSleep.rawValue,
            localizedTitle: QuickActionType.startSleep.title,
            localizedSubtitle: "2 Hz Delta waves",
            icon: QuickActionType.startSleep.icon,
            userInfo: nil
        )

        UIApplication.shared.shortcutItems = [
            playLastSession,
            startMeditation,
            startFocus,
            startSleep
        ]
    }

    // MARK: - Handle Action

    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let actionType = QuickActionType(rawValue: shortcutItem.type) else {
            return false
        }

        DispatchQueue.main.async {
            self.pendingAction = actionType
        }

        return true
    }

    func clearPendingAction() {
        pendingAction = nil
    }

    // MARK: - Quick Action Presets

    func getMeditationPreset() -> BinauralBeatPreset {
        return BinauralBeatPreset(
            name: "Quick Meditation",
            baseFrequency: 200,
            beatFrequency: 10,
            duration: 600,
            waveformType: .sine,
            rampConfig: nil,
            category: .meditation,
            tags: ["quick", "alpha", "meditation"]
        )
    }

    func getFocusPreset() -> BinauralBeatPreset {
        return BinauralBeatPreset(
            name: "Quick Focus",
            baseFrequency: 200,
            beatFrequency: 20,
            duration: 1800,
            waveformType: .sine,
            rampConfig: nil,
            category: .focus,
            tags: ["quick", "beta", "focus"]
        )
    }

    func getSleepPreset() -> BinauralBeatPreset {
        return BinauralBeatPreset(
            name: "Quick Sleep",
            baseFrequency: 200,
            beatFrequency: 2,
            duration: 1800,
            waveformType: .sine,
            rampConfig: nil,
            category: .sleep,
            tags: ["quick", "delta", "sleep"]
        )
    }
}

// MARK: - App Delegate Integration

class QuickActionAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            QuickActionManager.shared.handleQuickAction(shortcutItem)
        }

        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = QuickActionSceneDelegate.self
        return sceneConfig
    }
}

class QuickActionSceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = QuickActionManager.shared.handleQuickAction(shortcutItem)
        completionHandler(handled)
    }
}

// MARK: - Quick Action Handler View Modifier

struct QuickActionHandler: ViewModifier {
    @ObservedObject var quickActionManager = QuickActionManager.shared
    let onAction: (QuickActionType) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: quickActionManager.pendingAction) { action in
                if let action = action {
                    onAction(action)
                    quickActionManager.clearPendingAction()
                }
            }
    }
}

extension View {
    func handleQuickActions(_ handler: @escaping (QuickActionType) -> Void) -> some View {
        modifier(QuickActionHandler(onAction: handler))
    }
}
