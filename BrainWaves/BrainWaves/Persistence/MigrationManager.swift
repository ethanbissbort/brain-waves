//
//  MigrationManager.swift
//  BrainWaves
//
//  Handles data migrations between app versions
//

import Foundation

/// Manages data migrations between app versions
final class MigrationManager {
    static let shared = MigrationManager()

    private let userDefaults = UserDefaults.standard
    private let currentSchemaVersion = 1
    private let schemaVersionKey = "data_schema_version"

    private init() {}

    /// Perform any necessary migrations
    func performMigrations() {
        let savedVersion = userDefaults.integer(forKey: schemaVersionKey)

        // No migration needed if already at current version
        if savedVersion == currentSchemaVersion {
            Logger.shared.persistenceInfo("Data schema is current (v\(currentSchemaVersion))")
            return
        }

        Logger.shared.persistenceInfo("Starting migration from v\(savedVersion) to v\(currentSchemaVersion)")

        do {
            // Perform migrations step by step
            if savedVersion < 1 {
                try migrateToV1()
            }

            // Future migrations would go here
            // if savedVersion < 2 {
            //     try migrateToV2()
            // }

            // Update schema version
            userDefaults.set(currentSchemaVersion, forKey: schemaVersionKey)
            Logger.shared.persistenceInfo("Migration completed successfully")

        } catch {
            Logger.shared.persistenceError(error)
            ErrorHandler.shared.handle(
                PersistenceError.migrationFailed(error.localizedDescription),
                title: "Migration Failed"
            )
        }
    }

    // MARK: - Migration Steps

    /// Migration to schema version 1 (initial schema)
    private func migrateToV1() throws {
        Logger.shared.persistenceInfo("Migrating to schema v1")

        // V1 is the initial schema, so we just need to validate existing data
        // and ensure default presets exist

        // Validate binaural presets
        if let data = userDefaults.data(forKey: AppConstants.Storage.binauralPresetsKey) {
            let decoder = JSONDecoder()
            if let presets = try? decoder.decode([BinauralBeatPreset].self, from: data) {
                // Validate all presets
                for preset in presets {
                    do {
                        try preset.validate()
                    } catch {
                        Logger.shared.persistenceError(error)
                        // Continue with other presets even if one fails
                    }
                }
            }
        }

        // Validate isochronic presets
        if let data = userDefaults.data(forKey: AppConstants.Storage.isochronicPresetsKey) {
            let decoder = JSONDecoder()
            if let presets = try? decoder.decode([IsochronicTonePreset].self, from: data) {
                // Validate all presets
                for preset in presets {
                    do {
                        try preset.validate()
                    } catch {
                        Logger.shared.persistenceError(error)
                        // Continue with other presets even if one fails
                    }
                }
            }
        }

        // Validate playlists
        if let data = userDefaults.data(forKey: AppConstants.Storage.playlistsKey) {
            let decoder = JSONDecoder()
            if let playlists = try? decoder.decode([Playlist].self, from: data) {
                // Validate all playlists
                for playlist in playlists {
                    do {
                        try playlist.validate()
                    } catch {
                        Logger.shared.persistenceError(error)
                        // Continue with other playlists even if one fails
                    }
                }
            }
        }
    }

    // MARK: - Backup & Restore

    /// Create a backup of all user data
    func createBackup() throws -> Data {
        Logger.shared.persistenceInfo("Creating data backup")

        let backup = DataBackup(
            schemaVersion: currentSchemaVersion,
            timestamp: Date(),
            binauralPresets: loadBinauralPresets(),
            isochronicPresets: loadIsochronicPresets(),
            playlists: loadPlaylists(),
            settings: BackupSettings(
                volume: SettingsManager.shared.volume
            )
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(backup)
            Logger.shared.persistenceInfo("Backup created successfully (\(data.count) bytes)")
            return data
        } catch {
            Logger.shared.persistenceError(error)
            throw PersistenceError.encodingFailed(error)
        }
    }

    /// Restore from a backup
    func restoreFromBackup(_ data: Data) throws {
        Logger.shared.persistenceInfo("Restoring from backup")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let backup = try decoder.decode(DataBackup.self, from: data)

            // Validate backup version
            if backup.schemaVersion > currentSchemaVersion {
                throw PersistenceError.migrationFailed(
                    "Backup is from a newer version (v\(backup.schemaVersion))"
                )
            }

            // Restore presets
            saveBinauralPresets(backup.binauralPresets)
            saveIsochronicPresets(backup.isochronicPresets)
            savePlaylists(backup.playlists)

            // Restore settings
            SettingsManager.shared.volume = backup.settings.volume

            Logger.shared.persistenceInfo("Backup restored successfully")

        } catch {
            Logger.shared.persistenceError(error)
            throw PersistenceError.decodingFailed(error)
        }
    }

    // MARK: - Private Helpers

    private func loadBinauralPresets() -> [BinauralBeatPreset] {
        guard let data = userDefaults.data(forKey: AppConstants.Storage.binauralPresetsKey),
              let presets = try? JSONDecoder().decode([BinauralBeatPreset].self, from: data) else {
            return []
        }
        return presets
    }

    private func loadIsochronicPresets() -> [IsochronicTonePreset] {
        guard let data = userDefaults.data(forKey: AppConstants.Storage.isochronicPresetsKey),
              let presets = try? JSONDecoder().decode([IsochronicTonePreset].self, from: data) else {
            return []
        }
        return presets
    }

    private func loadPlaylists() -> [Playlist] {
        guard let data = userDefaults.data(forKey: AppConstants.Storage.playlistsKey),
              let playlists = try? JSONDecoder().decode([Playlist].self, from: data) else {
            return []
        }
        return playlists
    }

    private func saveBinauralPresets(_ presets: [BinauralBeatPreset]) {
        if let data = try? JSONEncoder().encode(presets) {
            userDefaults.set(data, forKey: AppConstants.Storage.binauralPresetsKey)
        }
    }

    private func saveIsochronicPresets(_ presets: [IsochronicTonePreset]) {
        if let data = try? JSONEncoder().encode(presets) {
            userDefaults.set(data, forKey: AppConstants.Storage.isochronicPresetsKey)
        }
    }

    private func savePlaylists(_ playlists: [Playlist]) {
        if let data = try? JSONEncoder().encode(playlists) {
            userDefaults.set(data, forKey: AppConstants.Storage.playlistsKey)
        }
    }
}

// MARK: - Backup Models

struct DataBackup: Codable {
    let schemaVersion: Int
    let timestamp: Date
    let binauralPresets: [BinauralBeatPreset]
    let isochronicPresets: [IsochronicTonePreset]
    let playlists: [Playlist]
    let settings: BackupSettings
}

struct BackupSettings: Codable {
    let volume: Float
}
