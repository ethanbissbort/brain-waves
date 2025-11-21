//
//  FrequencyRamping.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation

/// Configuration for frequency ramping behavior
struct FrequencyRampConfig: Codable, Equatable {
    var enabled: Bool
    var rampType: AppConstants.RampType
    var rampCurve: AppConstants.RampCurve
    var startFrequency: Double
    var endFrequency: Double
    var rampDuration: TimeInterval // Duration of the ramp in seconds

    init(enabled: Bool = false,
         rampType: AppConstants.RampType = .none,
         rampCurve: AppConstants.RampCurve = .linear,
         startFrequency: Double = 10.0,
         endFrequency: Double = 2.0,
         rampDuration: TimeInterval = 600.0) {
        self.enabled = enabled
        self.rampType = rampType
        self.rampCurve = rampCurve
        self.startFrequency = startFrequency
        self.endFrequency = endFrequency
        self.rampDuration = rampDuration
    }

    /// Calculate the frequency at a given time based on ramp configuration
    func frequency(at time: TimeInterval, totalDuration: TimeInterval) -> Double {
        guard enabled, rampType != .none else {
            return startFrequency
        }

        let effectiveRampDuration = min(rampDuration, totalDuration)
        let progress = min(time / effectiveRampDuration, 1.0)

        switch rampType {
        case .none:
            return startFrequency

        case .ascending:
            return interpolate(from: startFrequency, to: endFrequency, progress: progress)

        case .descending:
            return interpolate(from: startFrequency, to: endFrequency, progress: progress)

        case .ascendingDescending:
            // First half ascends, second half descends
            let halfDuration = effectiveRampDuration / 2
            if time < halfDuration {
                let halfProgress = time / halfDuration
                return interpolate(from: startFrequency, to: endFrequency, progress: halfProgress)
            } else {
                let halfProgress = (time - halfDuration) / halfDuration
                return interpolate(from: endFrequency, to: startFrequency, progress: halfProgress)
            }

        case .descendingAscending:
            // First half descends, second half ascends
            let halfDuration = effectiveRampDuration / 2
            if time < halfDuration {
                let halfProgress = time / halfDuration
                return interpolate(from: startFrequency, to: endFrequency, progress: halfProgress)
            } else {
                let halfProgress = (time - halfDuration) / halfDuration
                return interpolate(from: endFrequency, to: startFrequency, progress: halfProgress)
            }
        }
    }

    private func interpolate(from start: Double, to end: Double, progress: Double) -> Double {
        let clampedProgress = max(0.0, min(1.0, progress))

        switch rampCurve {
        case .linear:
            return start + (end - start) * clampedProgress

        case .exponential:
            // Exponential curve: slow start, fast finish
            let exponentialProgress = pow(clampedProgress, 2)
            return start + (end - start) * exponentialProgress

        case .logarithmic:
            // Logarithmic curve: fast start, slow finish
            let logarithmicProgress = sqrt(clampedProgress)
            return start + (end - start) * logarithmicProgress
        }
    }
}
