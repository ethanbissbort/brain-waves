//
//  PresetStore.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class PresetStore: ObservableObject, PresetStoreProtocol {
    static let shared = PresetStore()

    @Published var binauralPresets: [BinauralBeatPreset] = []
    @Published var isochronicPresets: [IsochronicTonePreset] = []
    @Published var multiLayerPresets: [MultiLayerPreset] = []
    @Published var playlists: [Playlist] = []

    private let binauralPresetsKey = "saved_binaural_presets"
    private let isochronicPresetsKey = "saved_isochronic_presets"
    private let multiLayerPresetsKey = "saved_multilayer_presets"
    private let playlistsKey = "playlists"

    private init() {
        // Perform any necessary migrations first
        MigrationManager.shared.performMigrations()

        loadAll()
        // If no presets exist, add default ones
        if binauralPresets.isEmpty {
            binauralPresets = BinauralBeatPreset.defaultPresets
            saveBinauralPresets()
        }
        if isochronicPresets.isEmpty {
            isochronicPresets = IsochronicTonePreset.defaultPresets
            saveIsochronicPresets()
        }
        if multiLayerPresets.isEmpty {
            multiLayerPresets = MultiLayerPreset.defaultPresets
            saveMultiLayerPresets()
        }
    }

    // MARK: - Binaural Beat Presets

    func addBinauralPreset(_ preset: BinauralBeatPreset) {
        do {
            try preset.validate()
            binauralPresets.append(preset)
            saveBinauralPresets()
            Logger.shared.persistenceInfo("Added binaural preset: \(preset.name)")
        } catch {
            Logger.shared.persistenceError(error)
            ErrorHandler.shared.handle(error, title: "Invalid Preset")
        }
    }

    func updateBinauralPreset(_ preset: BinauralBeatPreset) {
        do {
            try preset.validate()
            if let index = binauralPresets.firstIndex(where: { $0.id == preset.id }) {
                binauralPresets[index] = preset
                saveBinauralPresets()
                Logger.shared.persistenceInfo("Updated binaural preset: \(preset.name)")
            }
        } catch {
            Logger.shared.persistenceError(error)
            ErrorHandler.shared.handle(error, title: "Invalid Preset")
        }
    }

    func deleteBinauralPreset(_ preset: BinauralBeatPreset) {
        binauralPresets.removeAll { $0.id == preset.id }
        saveBinauralPresets()
    }

    private func saveBinauralPresets() {
        if let encoded = try? JSONEncoder().encode(binauralPresets) {
            UserDefaults.standard.set(encoded, forKey: binauralPresetsKey)
        }
    }

    private func loadBinauralPresets() {
        if let data = UserDefaults.standard.data(forKey: binauralPresetsKey),
           let decoded = try? JSONDecoder().decode([BinauralBeatPreset].self, from: data) {
            binauralPresets = decoded
        }
    }

    // MARK: - Isochronic Tone Presets

    func addIsochronicPreset(_ preset: IsochronicTonePreset) {
        do {
            try preset.validate()
            isochronicPresets.append(preset)
            saveIsochronicPresets()
            Logger.shared.persistenceInfo("Added isochronic preset: \(preset.name)")
        } catch {
            Logger.shared.persistenceError(error)
            ErrorHandler.shared.handle(error, title: "Invalid Preset")
        }
    }

    func updateIsochronicPreset(_ preset: IsochronicTonePreset) {
        do {
            try preset.validate()
            if let index = isochronicPresets.firstIndex(where: { $0.id == preset.id }) {
                isochronicPresets[index] = preset
                saveIsochronicPresets()
                Logger.shared.persistenceInfo("Updated isochronic preset: \(preset.name)")
            }
        } catch {
            Logger.shared.persistenceError(error)
            ErrorHandler.shared.handle(error, title: "Invalid Preset")
        }
    }

    func deleteIsochronicPreset(_ preset: IsochronicTonePreset) {
        isochronicPresets.removeAll { $0.id == preset.id }
        saveIsochronicPresets()
    }

    private func saveIsochronicPresets() {
        if let encoded = try? JSONEncoder().encode(isochronicPresets) {
            UserDefaults.standard.set(encoded, forKey: isochronicPresetsKey)
        }
    }

    private func loadIsochronicPresets() {
        if let data = UserDefaults.standard.data(forKey: isochronicPresetsKey),
           let decoded = try? JSONDecoder().decode([IsochronicTonePreset].self, from: data) {
            isochronicPresets = decoded
        }
    }

    // MARK: - Multi-Layer Presets

    func addMultiLayerPreset(_ preset: MultiLayerPreset) {
        multiLayerPresets.append(preset)
        saveMultiLayerPresets()
        Logger.shared.persistenceInfo("Added multi-layer preset: \(preset.name)")
    }

    func updateMultiLayerPreset(_ preset: MultiLayerPreset) {
        if let index = multiLayerPresets.firstIndex(where: { $0.id == preset.id }) {
            multiLayerPresets[index] = preset
            saveMultiLayerPresets()
            Logger.shared.persistenceInfo("Updated multi-layer preset: \(preset.name)")
        }
    }

    func deleteMultiLayerPreset(_ preset: MultiLayerPreset) {
        multiLayerPresets.removeAll { $0.id == preset.id }
        saveMultiLayerPresets()
    }

    private func saveMultiLayerPresets() {
        if let encoded = try? JSONEncoder().encode(multiLayerPresets) {
            UserDefaults.standard.set(encoded, forKey: multiLayerPresetsKey)
        }
    }

    private func loadMultiLayerPresets() {
        if let data = UserDefaults.standard.data(forKey: multiLayerPresetsKey),
           let decoded = try? JSONDecoder().decode([MultiLayerPreset].self, from: data) {
            multiLayerPresets = decoded
        }
    }

    // MARK: - Playlists

    func addPlaylist(_ playlist: Playlist) {
        do {
            try playlist.validate()
            playlists.append(playlist)
            savePlaylists()
            Logger.shared.persistenceInfo("Added playlist: \(playlist.name)")
        } catch {
            Logger.shared.persistenceError(error)
            ErrorHandler.shared.handle(error, title: "Invalid Playlist")
        }
    }

    func updatePlaylist(_ playlist: Playlist) {
        do {
            try playlist.validate()
            if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
                playlists[index] = playlist
                savePlaylists()
                Logger.shared.persistenceInfo("Updated playlist: \(playlist.name)")
            }
        } catch {
            Logger.shared.persistenceError(error)
            ErrorHandler.shared.handle(error, title: "Invalid Playlist")
        }
    }

    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
        savePlaylists()
    }

    private func savePlaylists() {
        if let encoded = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(encoded, forKey: playlistsKey)
        }
    }

    private func loadPlaylists() {
        if let data = UserDefaults.standard.data(forKey: playlistsKey),
           let decoded = try? JSONDecoder().decode([Playlist].self, from: data) {
            playlists = decoded
        }
    }

    // MARK: - Load All

    private func loadAll() {
        loadBinauralPresets()
        loadIsochronicPresets()
        loadMultiLayerPresets()
        loadPlaylists()
    }

    // MARK: - Helper Methods

    func getBinauralPreset(byId id: UUID) -> BinauralBeatPreset? {
        binauralPresets.first { $0.id == id }
    }

    func getIsochronicPreset(byId id: UUID) -> IsochronicTonePreset? {
        isochronicPresets.first { $0.id == id }
    }

    func getMultiLayerPreset(byId id: UUID) -> MultiLayerPreset? {
        multiLayerPresets.first { $0.id == id }
    }
}
