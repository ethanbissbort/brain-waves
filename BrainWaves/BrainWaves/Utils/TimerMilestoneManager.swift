//
//  TimerMilestoneManager.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import UserNotifications
import SwiftUI

class TimerMilestoneManager: ObservableObject {
    static let shared = TimerMilestoneManager()

    @Published var showCompletionAlert = false
    @Published var completionMessage = ""

    private var lastNotifiedMinute: Int = -1
    private var notificationScheduled = false

    private init() {
        requestNotificationPermission()
    }

    // MARK: - Notification Permission

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }

    // MARK: - Milestone Tracking

    func checkMilestone(remainingTime: TimeInterval, isPlaying: Bool) {
        guard isPlaying else {
            lastNotifiedMinute = -1
            return
        }

        let remainingMinutes = Int(remainingTime / 60)
        let remainingSeconds = Int(remainingTime.truncatingRemainder(dividingBy: 60))

        // Notify at specific milestones
        let milestones = [10, 5, 3, 2, 1]

        if milestones.contains(remainingMinutes) && remainingSeconds == 0 && remainingMinutes != lastNotifiedMinute {
            notifyMilestone(minutes: remainingMinutes)
            lastNotifiedMinute = remainingMinutes
        }

        // Notify at 30 seconds
        if remainingTime <= 30 && remainingTime > 29 && lastNotifiedMinute != 0 {
            notifyMilestone(minutes: 0)
            lastNotifiedMinute = 0
        }
    }

    private func notifyMilestone(minutes: Int) {
        HapticManager.shared.playSelection()

        if minutes == 0 {
            completionMessage = "30 seconds remaining!"
        } else {
            completionMessage = "\(minutes) minute\(minutes == 1 ? "" : "s") remaining!"
        }

        // Show brief alert
        withAnimation {
            showCompletionAlert = true
        }

        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showCompletionAlert = false
            }
        }
    }

    // MARK: - Session Completion

    func notifyCompletion(sessionType: String) {
        HapticManager.shared.playTimerComplete()

        completionMessage = "\(sessionType) session completed!"

        withAnimation {
            showCompletionAlert = true
        }

        // Send local notification if app is in background
        scheduleCompletionNotification(sessionType: sessionType)

        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showCompletionAlert = false
            }
        }
    }

    // MARK: - Background Notifications

    func scheduleSessionCompletion(duration: TimeInterval, sessionType: String) {
        // Cancel any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Brain Waves Session Complete"
        content.body = "Your \(sessionType) session has finished!"
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "sessionComplete", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                self.notificationScheduled = true
            }
        }
    }

    func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationScheduled = false
    }

    private func scheduleCompletionNotification(sessionType: String) {
        let content = UNMutableNotificationContent()
        content.title = "Brain Waves Session Complete"
        content.body = "Your \(sessionType) session has finished!"
        content.sound = .default
        content.badge = 1

        // Immediate notification (1 second delay to ensure it shows)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "sessionCompleteImmediate", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Reset

    func reset() {
        lastNotifiedMinute = -1
        showCompletionAlert = false
        cancelScheduledNotifications()
    }
}

// MARK: - Milestone Alert View

struct MilestoneAlertView: View {
    let message: String
    let isVisible: Bool

    var body: some View {
        if isVisible {
            VStack {
                Spacer()

                HStack {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.title2)
                        .foregroundColor(.white)

                    Text(message)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                        .shadow(radius: 10)
                )
                .padding(.bottom, 50)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.3), value: isVisible)
        }
    }
}
