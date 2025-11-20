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

    init(id: UUID = UUID(),
         name: String,
         items: [PlaylistItem] = [],
         createdDate: Date = Date(),
         modifiedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.items = items
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
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
        guard from < items.count && to <= items.count else { return }
        let item = items.remove(at: from)
        items.insert(item, at: to)
        reorderItems()
        modifiedDate = Date()
    }

    private mutating func reorderItems() {
        for (index, _) in items.enumerated() {
            items[index].order = index
        }
    }
}
