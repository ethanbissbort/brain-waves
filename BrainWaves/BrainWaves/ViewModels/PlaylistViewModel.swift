//
//  PlaylistViewModel.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import Combine

class PlaylistViewModel: ObservableObject {
    @Published var currentPlaylist: Playlist?
    @Published var currentItemIndex: Int = 0
    @Published var isPlayingPlaylist = false
    @Published var showingCreatePlaylist = false
    @Published var newPlaylistName = ""

    private let presetStore = PresetStore.shared
    private var binauralGenerator = BinauralBeatsGenerator()
    private var isochronicGenerator = IsochronicTonesGenerator()
    private var cancellables = Set<AnyCancellable>()

    func createPlaylist(name: String) {
        let playlist = Playlist(name: name)
        presetStore.addPlaylist(playlist)
        newPlaylistName = ""
        showingCreatePlaylist = false
    }

    func createPlaylist(from template: Playlist) {
        presetStore.addPlaylist(template)
    }

    func updatePlaylist(_ playlist: Playlist) {
        presetStore.updatePlaylist(playlist)
    }

    func addItemToPlaylist(playlist: Playlist, presetId: UUID, type: PresetType) {
        var updatedPlaylist = playlist
        updatedPlaylist.addItem(presetId: presetId, type: type)
        presetStore.updatePlaylist(updatedPlaylist)
    }

    func removeItemFromPlaylist(playlist: Playlist, at index: Int) {
        var updatedPlaylist = playlist
        updatedPlaylist.removeItem(at: index)
        presetStore.updatePlaylist(updatedPlaylist)
    }

    func moveItemInPlaylist(playlist: Playlist, from: Int, to: Int) {
        var updatedPlaylist = playlist
        updatedPlaylist.moveItem(from: from, to: to)
        presetStore.updatePlaylist(updatedPlaylist)
    }

    func playPlaylist(_ playlist: Playlist) {
        guard !playlist.items.isEmpty else { return }

        currentPlaylist = playlist
        currentItemIndex = 0
        isPlayingPlaylist = true

        playCurrentItem()
    }

    func stopPlaylist() {
        binauralGenerator.stop()
        isochronicGenerator.stop()
        isPlayingPlaylist = false
        currentPlaylist = nil
        currentItemIndex = 0
    }

    private func playCurrentItem() {
        guard let playlist = currentPlaylist,
              currentItemIndex < playlist.items.count else {
            stopPlaylist()
            return
        }

        let item = playlist.items[currentItemIndex]

        switch item.type {
        case .binaural:
            if let preset = presetStore.getBinauralPreset(byId: item.presetId) {
                playBinauralPreset(preset)
            } else {
                playNextItem()
            }

        case .isochronic:
            if let preset = presetStore.getIsochronicPreset(byId: item.presetId) {
                playIsochronicPreset(preset)
            } else {
                playNextItem()
            }
        }
    }

    private func playBinauralPreset(_ preset: BinauralBeatPreset) {
        // Stop isochronic if playing
        isochronicGenerator.stop()

        binauralGenerator.start(
            baseFrequency: preset.baseFrequency,
            beatFrequency: preset.beatFrequency,
            duration: preset.duration
        )

        // Monitor completion
        Timer.scheduledTimer(withTimeInterval: preset.duration, repeats: false) { [weak self] _ in
            self?.playNextItem()
        }
    }

    private func playIsochronicPreset(_ preset: IsochronicTonePreset) {
        // Stop binaural if playing
        binauralGenerator.stop()

        isochronicGenerator.start(
            carrierFrequency: preset.carrierFrequency,
            pulseFrequency: preset.pulseFrequency,
            duration: preset.duration
        )

        // Monitor completion
        Timer.scheduledTimer(withTimeInterval: preset.duration, repeats: false) { [weak self] _ in
            self?.playNextItem()
        }
    }

    private func playNextItem() {
        guard let playlist = currentPlaylist else { return }

        currentItemIndex += 1

        if currentItemIndex < playlist.items.count {
            playCurrentItem()
        } else {
            stopPlaylist()
        }
    }

    func deletePlaylist(_ playlist: Playlist) {
        if currentPlaylist?.id == playlist.id {
            stopPlaylist()
        }
        presetStore.deletePlaylist(playlist)
    }
}
