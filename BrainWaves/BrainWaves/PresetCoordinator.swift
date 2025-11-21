//
//  PresetCoordinator.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class PresetCoordinator: ObservableObject, PresetCoordinatorProtocol {
    static let shared = PresetCoordinator()

    @Published var selectedBinauralPreset: BinauralBeatPreset?
    @Published var selectedIsochronicPreset: IsochronicTonePreset?
    @Published var shouldNavigateToBinaural = false
    @Published var shouldNavigateToIsochronic = false

    private init() {}

    func selectBinauralPreset(_ preset: BinauralBeatPreset) {
        selectedBinauralPreset = preset
        shouldNavigateToBinaural = true

        // Reset after a delay to allow for reselection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.shouldNavigateToBinaural = false
        }
    }

    func selectIsochronicPreset(_ preset: IsochronicTonePreset) {
        selectedIsochronicPreset = preset
        shouldNavigateToIsochronic = true

        // Reset after a delay to allow for reselection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.shouldNavigateToIsochronic = false
        }
    }

    func clearBinauralPreset() {
        selectedBinauralPreset = nil
    }

    func clearIsochronicPreset() {
        selectedIsochronicPreset = nil
    }
}
