//
//  ErrorHandler.swift
//  BrainWaves
//
//  Central error handling and user-facing error presentation
//

import Foundation
import SwiftUI

/// Central error handling coordinator
final class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()

    @Published var currentError: ErrorPresentation?
    @Published var showingError = false

    private init() {}

    /// Present an error to the user
    func handle(_ error: Error, title: String? = nil) {
        Logger.shared.error(error)

        let presentation = ErrorPresentation(
            title: title ?? "Error",
            message: errorMessage(for: error),
            recoverySuggestion: errorRecoverySuggestion(for: error)
        )

        DispatchQueue.main.async {
            self.currentError = presentation
            self.showingError = true
        }
    }

    /// Handle an error silently (log but don't show to user)
    func handleSilently(_ error: Error) {
        Logger.shared.error(error)
    }

    /// Dismiss the current error
    func dismissError() {
        currentError = nil
        showingError = false
    }

    // MARK: - Private Helpers

    private func errorMessage(for error: Error) -> String {
        if let brainWavesError = error as? BrainWavesError {
            return brainWavesError.errorDescription ?? "An unknown error occurred"
        }
        return error.localizedDescription
    }

    private func errorRecoverySuggestion(for error: Error) -> String? {
        if let brainWavesError = error as? BrainWavesError {
            return brainWavesError.recoverySuggestion
        }
        return nil
    }
}

/// Error presentation model for UI
struct ErrorPresentation: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let recoverySuggestion: String?

    var alertMessage: String {
        if let suggestion = recoverySuggestion {
            return "\(message)\n\n\(suggestion)"
        }
        return message
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Attach error handling to a view
    func errorHandling() -> some View {
        modifier(ErrorHandlingModifier())
    }
}

struct ErrorHandlingModifier: ViewModifier {
    @ObservedObject private var errorHandler = ErrorHandler.shared

    func body(content: Content) -> some View {
        content
            .alert(
                errorHandler.currentError?.title ?? "Error",
                isPresented: $errorHandler.showingError,
                presenting: errorHandler.currentError
            ) { _ in
                Button("OK") {
                    errorHandler.dismissError()
                }
            } message: { error in
                Text(error.alertMessage)
            }
    }
}
