//
//  PlaylistView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct PlaylistView: View {
    @ObservedObject var presetStore = PresetStore.shared
    @StateObject private var viewModel = PlaylistViewModel()
    @State private var selectedPlaylist: Playlist?
    @State private var showingTemplates = false

    var body: some View {
        NavigationView {
            List {
                ForEach(presetStore.playlists) { playlist in
                    NavigationLink(destination: PlaylistDetailView(playlist: playlist, viewModel: viewModel)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(playlist.name)
                                .font(.headline)

                            Text("\(playlist.items.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let playlist = presetStore.playlists[index]
                        viewModel.deletePlaylist(playlist)
                    }
                }
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingTemplates = true
                    }) {
                        Label("Templates", systemImage: "square.stack.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingCreatePlaylist = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreatePlaylist) {
                CreatePlaylistSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingTemplates) {
                PlaylistTemplateSelector(isPresented: $showingTemplates) { template in
                    viewModel.createPlaylist(from: template)
                }
            }
        }
    }
}

struct CreatePlaylistSheet: View {
    @ObservedObject var viewModel: PlaylistViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create New Playlist")
                    .font(.headline)

                TextField("Playlist Name", text: $viewModel.newPlaylistName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Create") {
                    viewModel.createPlaylist(name: viewModel.newPlaylistName)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.newPlaylistName.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.newPlaylistName = ""
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlaylistDetailView: View {
    let playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModel
    @ObservedObject var presetStore = PresetStore.shared
    @State private var editMode = EditMode.inactive
    @State private var showingAddPreset = false
    @State private var localPlaylist: Playlist

    init(playlist: Playlist, viewModel: PlaylistViewModel) {
        self.playlist = playlist
        self.viewModel = viewModel
        _localPlaylist = State(initialValue: playlist)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Playlist Controls
            ScrollView {
                VStack(spacing: 12) {
                    PlaylistControlsView(playlist: $localPlaylist)
                        .onChange(of: localPlaylist) { updatedPlaylist in
                            viewModel.updatePlaylist(updatedPlaylist)
                        }
                }
                .padding()
            }
            .frame(maxHeight: 300)

            Divider()

            List {
                ForEach(playlist.items) { item in
                    PlaylistItemRow(item: item, presetStore: presetStore)
                }
                .onMove { from, to in
                    viewModel.moveItemInPlaylist(playlist: playlist, from: from.first!, to: to)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel.removeItemFromPlaylist(playlist: playlist, at: index)
                    }
                }
            }
            .environment(\.editMode, $editMode)

            // Playback controls for playlist
            if !playlist.items.isEmpty {
                VStack(spacing: 12) {
                    if viewModel.isPlayingPlaylist && viewModel.currentPlaylist?.id == playlist.id {
                        Text("Playing: \(viewModel.currentItemIndex + 1) of \(playlist.items.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: {
                            viewModel.stopPlaylist()
                        }) {
                            Label("Stop Playlist", systemImage: "stop.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            viewModel.playPlaylist(playlist)
                        }) {
                            Label("Play Playlist", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddPreset = true
                }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddPreset) {
            AddPresetToPlaylistSheet(playlist: playlist, viewModel: viewModel)
        }
    }
}

struct PlaylistItemRow: View {
    let item: PlaylistItem
    @ObservedObject var presetStore: PresetStore

    var body: some View {
        HStack {
            Image(systemName: item.type == .binaural ? "waveform.path" : "waveform")
                .foregroundColor(item.type == .binaural ? .blue : .purple)

            VStack(alignment: .leading, spacing: 4) {
                if item.type == .binaural,
                   let preset = presetStore.getBinauralPreset(byId: item.presetId) {
                    Text(preset.name)
                        .font(.body)
                    Text("Binaural • \(formatDuration(preset.duration))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if item.type == .isochronic,
                          let preset = presetStore.getIsochronicPreset(byId: item.presetId) {
                    Text(preset.name)
                        .font(.body)
                    Text("Isochronic • \(formatDuration(preset.duration))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Unknown Preset")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct AddPresetToPlaylistSheet: View {
    let playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModel
    @ObservedObject var presetStore = PresetStore.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedSegment = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("Preset Type", selection: $selectedSegment) {
                    Text("Binaural Beats").tag(0)
                    Text("Isochronic Tones").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedSegment == 0 {
                    List(presetStore.binauralPresets) { preset in
                        Button(action: {
                            viewModel.addItemToPlaylist(
                                playlist: playlist,
                                presetId: preset.id,
                                type: .binaural
                            )
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preset.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("Base: \(String(format: "%.1f Hz", preset.baseFrequency)) • Beat: \(String(format: "%.1f Hz", preset.beatFrequency))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    List(presetStore.isochronicPresets) { preset in
                        Button(action: {
                            viewModel.addItemToPlaylist(
                                playlist: playlist,
                                presetId: preset.id,
                                type: .isochronic
                            )
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preset.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("Carrier: \(String(format: "%.1f Hz", preset.carrierFrequency)) • Pulse: \(String(format: "%.1f Hz", preset.pulseFrequency))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Add Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
