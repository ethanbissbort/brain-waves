//
//  Playlist.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation

enum PresetType: String, Codable {
    case binaural
    case isochronic
}

enum RepeatMode: String, Codable, CaseIterable {
    case off = "Off"
    case one = "Repeat One"
    case all = "Repeat All"

    var icon: String {
        switch self {
        case .off:
            return "repeat"
        case .one:
            return "repeat.1"
        case .all:
            return "repeat"
        }
    }
}

struct PlaylistItem: Codable, Identifiable, Equatable {
    let id: UUID
    let presetId: UUID
    let type: PresetType
    var order: Int

    init(id: UUID = UUID(), presetId: UUID, type: PresetType, order: Int) {
        self.id = id
        self.presetId = presetId
        self.type = type
        self.order = order
    }
}

struct Playlist: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var items: [PlaylistItem]
    var createdDate: Date
    var modifiedDate: Date

    // Playback settings
    var shuffleEnabled: Bool = false
    var repeatMode: RepeatMode = .off
    var crossfadeDuration: TimeInterval = 3.0 // seconds

    init(id: UUID = UUID(),
         name: String,
         items: [PlaylistItem] = [],
         createdDate: Date = Date(),
         modifiedDate: Date = Date(),
         shuffleEnabled: Bool = false,
         repeatMode: RepeatMode = .off,
         crossfadeDuration: TimeInterval = 3.0) {
        self.id = id
        self.name = name
        self.items = items
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.shuffleEnabled = shuffleEnabled
        self.repeatMode = repeatMode
        self.crossfadeDuration = crossfadeDuration
    }

    enum CodingKeys: String, CodingKey {
        case id, name, items, createdDate, modifiedDate, shuffleEnabled, repeatMode, crossfadeDuration
    }

    // Custom decoding tolerates legacy playlists persisted before the shuffleEnabled/repeatMode/
    // crossfadeDuration playback settings were introduced (Phase 2). These fields are non-optional,
    // so the synthesized decoder would throw `keyNotFound` on old data and `try?` would silently drop
    // every saved playlist. Missing keys fall back to the same defaults as the memberwise init.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        items = try container.decodeIfPresent([PlaylistItem].self, forKey: .items) ?? []
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
        modifiedDate = try container.decodeIfPresent(Date.self, forKey: .modifiedDate) ?? Date()
        shuffleEnabled = try container.decodeIfPresent(Bool.self, forKey: .shuffleEnabled) ?? false
        repeatMode = try container.decodeIfPresent(RepeatMode.self, forKey: .repeatMode) ?? .off
        crossfadeDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .crossfadeDuration) ?? 3.0
    }

    mutating func addItem(presetId: UUID, type: PresetType) {
        let newItem = PlaylistItem(
            presetId: presetId,
            type: type,
            order: items.count
        )
        items.append(newItem)
        modifiedDate = Date()
    }

    mutating func removeItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        reorderItems()
        modifiedDate = Date()
    }

    mutating func moveItem(from: Int, to: Int) {
        guard from >= 0, to >= 0, from < items.count, to <= items.count else { return }
        let item = items.remove(at: from)
        // After removal the array is one shorter, so an insertion index equal to the original
        // count (a valid "move to end" request) would be out of bounds. Clamp to the new count.
        let target = min(to, items.count)
        items.insert(item, at: target)
        reorderItems()
        modifiedDate = Date()
    }

    private mutating func reorderItems() {
        for (index, _) in items.enumerated() {
            items[index].order = index
        }
    }

    // MARK: - Playback Helpers

    func getPlaybackOrder() -> [PlaylistItem] {
        if shuffleEnabled {
            return items.shuffled()
        } else {
            return items
        }
    }

    func getNextItem(after currentItem: PlaylistItem, in playbackOrder: [PlaylistItem]) -> PlaylistItem? {
        guard let currentIndex = playbackOrder.firstIndex(where: { $0.id == currentItem.id }) else {
            return nil
        }

        switch repeatMode {
        case .off:
            // Next item, or nil if at end
            let nextIndex = currentIndex + 1
            return nextIndex < playbackOrder.count ? playbackOrder[nextIndex] : nil

        case .one:
            // Repeat current item
            return currentItem

        case .all:
            // Next item, or wrap to beginning
            let nextIndex = currentIndex + 1
            return nextIndex < playbackOrder.count ? playbackOrder[nextIndex] : playbackOrder.first
        }
    }

    func getPreviousItem(before currentItem: PlaylistItem, in playbackOrder: [PlaylistItem]) -> PlaylistItem? {
        guard let currentIndex = playbackOrder.firstIndex(where: { $0.id == currentItem.id }) else {
            return nil
        }

        let previousIndex = currentIndex - 1
        if previousIndex >= 0 {
            return playbackOrder[previousIndex]
        } else if repeatMode == .all {
            // Wrap to end
            return playbackOrder.last
        } else {
            return nil
        }
    }

    // MARK: - Playlist Templates

    static func morningEnergyTemplate() -> Playlist {
        // Template for morning energy boost
        return Playlist(
            name: "Morning Energy",
            items: [],
            repeatMode: .all,
            crossfadeDuration: 5.0
        )
    }

    static func deepFocusTemplate() -> Playlist {
        // Template for deep focus sessions
        return Playlist(
            name: "Deep Focus",
            items: [],
            repeatMode: .all,
            crossfadeDuration: 4.0
        )
    }

    static func meditationJourneyTemplate() -> Playlist {
        // Template for progressive meditation
        return Playlist(
            name: "Meditation Journey",
            items: [],
            repeatMode: .off,
            crossfadeDuration: 6.0
        )
    }

    static func sleepCycleTemplate() -> Playlist {
        // Template for sleep progression
        return Playlist(
            name: "Sleep Cycle",
            items: [],
            repeatMode: .off,
            crossfadeDuration: 8.0
        )
    }
}
