//
//  Logger.swift
//  BrainWaves
//
//  Centralized logging infrastructure using OSLog
//

import Foundation
import OSLog

/// Centralized logger using OSLog for better debugging and diagnostics
final class Logger {
    static let shared = Logger()

    // Subsystem identifier for the app
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.brainwaves.app"

    // Category-specific loggers
    private let audioLogger: os.Logger
    private let persistenceLogger: os.Logger
    private let uiLogger: os.Logger
    private let generalLogger: os.Logger

    private init() {
        audioLogger = os.Logger(subsystem: subsystem, category: "Audio")
        persistenceLogger = os.Logger(subsystem: subsystem, category: "Persistence")
        uiLogger = os.Logger(subsystem: subsystem, category: "UI")
        generalLogger = os.Logger(subsystem: subsystem, category: "General")
    }

    // MARK: - Audio Logging

    func audioInfo(_ message: String) {
        audioLogger.info("\(message, privacy: .public)")
    }

    func audioDebug(_ message: String) {
        audioLogger.debug("\(message, privacy: .public)")
    }

    func audioError(_ error: Error) {
        audioLogger.error("Audio Error: \(error.localizedDescription, privacy: .public)")
    }

    // MARK: - Persistence Logging

    func persistenceInfo(_ message: String) {
        persistenceLogger.info("\(message, privacy: .public)")
    }

    func persistenceDebug(_ message: String) {
        persistenceLogger.debug("\(message, privacy: .public)")
    }

    func persistenceError(_ error: Error) {
        persistenceLogger.error("Persistence Error: \(error.localizedDescription, privacy: .public)")
    }

    // MARK: - UI Logging

    func uiInfo(_ message: String) {
        uiLogger.info("\(message, privacy: .public)")
    }

    func uiDebug(_ message: String) {
        uiLogger.debug("\(message, privacy: .public)")
    }

    func uiError(_ error: Error) {
        uiLogger.error("UI Error: \(error.localizedDescription, privacy: .public)")
    }

    // MARK: - General Logging

    func info(_ message: String) {
        generalLogger.info("\(message, privacy: .public)")
    }

    func debug(_ message: String) {
        generalLogger.debug("\(message, privacy: .public)")
    }

    func warning(_ message: String) {
        generalLogger.warning("\(message, privacy: .public)")
    }

    func error(_ error: Error) {
        if let brainWavesError = error as? BrainWavesError {
            generalLogger.error("[\(brainWavesError.errorCode)] \(error.localizedDescription, privacy: .public)")
        } else {
            generalLogger.error("Error: \(error.localizedDescription, privacy: .public)")
        }
    }

    func fault(_ message: String) {
        generalLogger.fault("\(message, privacy: .public)")
    }

    // MARK: - Convenience Methods

    /// Log a function entry (useful for debugging flow)
    func trace(function: String = #function, file: String = #file) {
        let fileName = (file as NSString).lastPathComponent
        generalLogger.debug("→ \(fileName).\(function)")
    }

    /// Log method execution time
    func measure<T>(_ operation: String, block: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            generalLogger.debug("⏱ \(operation) took \(String(format: "%.3f", elapsed))s")
        }
        return try block()
    }
}

// MARK: - Debug Extensions

#if DEBUG
extension Logger {
    /// Print to console in debug builds (for development)
    func printDebug(_ message: String) {
        print("[DEBUG] \(message)")
    }
}
#endif
