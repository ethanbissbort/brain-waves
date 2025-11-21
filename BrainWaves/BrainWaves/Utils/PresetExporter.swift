//
//  PresetExporter.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import Foundation
import UIKit

enum PresetExportFormat {
    case json
    case text
}

struct PresetExporter {

    // MARK: - Export Methods

    /// Export a binaural beat preset to JSON
    static func exportBinauralPreset(_ preset: BinauralBeatPreset, format: PresetExportFormat = .json) -> Result<String, Error> {
        switch format {
        case .json:
            return exportToJSON(preset)
        case .text:
            return exportToText(preset)
        }
    }

    /// Export an isochronic tone preset to JSON
    static func exportIsochronicPreset(_ preset: IsochronicTonePreset, format: PresetExportFormat = .json) -> Result<String, Error> {
        switch format {
        case .json:
            return exportToJSON(preset)
        case .text:
            return exportToText(preset)
        }
    }

    /// Export multiple binaural presets
    static func exportBinauralPresets(_ presets: [BinauralBeatPreset]) -> Result<String, Error> {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(presets)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return .failure(ExportError.encodingFailed)
            }
            return .success(jsonString)
        } catch {
            return .failure(error)
        }
    }

    /// Export multiple isochronic presets
    static func exportIsochronicPresets(_ presets: [IsochronicTonePreset]) -> Result<String, Error> {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(presets)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return .failure(ExportError.encodingFailed)
            }
            return .success(jsonString)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Import Methods

    /// Import a binaural beat preset from JSON
    static func importBinauralPreset(from jsonString: String) -> Result<BinauralBeatPreset, Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(ExportError.invalidInput)
        }

        do {
            let decoder = JSONDecoder()
            let preset = try decoder.decode(BinauralBeatPreset.self, from: data)
            return .success(preset)
        } catch {
            return .failure(error)
        }
    }

    /// Import an isochronic tone preset from JSON
    static func importIsochronicPreset(from jsonString: String) -> Result<IsochronicTonePreset, Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(ExportError.invalidInput)
        }

        do {
            let decoder = JSONDecoder()
            let preset = try decoder.decode(IsochronicTonePreset.self, from: data)
            return .success(preset)
        } catch {
            return .failure(error)
        }
    }

    /// Import multiple binaural presets from JSON
    static func importBinauralPresets(from jsonString: String) -> Result<[BinauralBeatPreset], Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(ExportError.invalidInput)
        }

        do {
            let decoder = JSONDecoder()
            let presets = try decoder.decode([BinauralBeatPreset].self, from: data)
            return .success(presets)
        } catch {
            return .failure(error)
        }
    }

    /// Import multiple isochronic presets from JSON
    static func importIsochronicPresets(from jsonString: String) -> Result<[IsochronicTonePreset], Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(ExportError.invalidInput)
        }

        do {
            let decoder = JSONDecoder()
            let presets = try decoder.decode([IsochronicTonePreset].self, from: data)
            return .success(presets)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - File Sharing

    /// Create a shareable file for a preset
    static func createShareableFile(for preset: BinauralBeatPreset) -> Result<URL, Error> {
        let result = exportBinauralPreset(preset)

        switch result {
        case .success(let jsonString):
            return saveToTempFile(jsonString, filename: "\(preset.name).brainwaves.json")
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Create a shareable file for a preset
    static func createShareableFile(for preset: IsochronicTonePreset) -> Result<URL, Error> {
        let result = exportIsochronicPreset(preset)

        switch result {
        case .success(let jsonString):
            return saveToTempFile(jsonString, filename: "\(preset.name).brainwaves.json")
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Private Helpers

    private static func exportToJSON<T: Encodable>(_ preset: T) -> Result<String, Error> {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(preset)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return .failure(ExportError.encodingFailed)
            }
            return .success(jsonString)
        } catch {
            return .failure(error)
        }
    }

    private static func exportToText(_ preset: BinauralBeatPreset) -> Result<String, Error> {
        var text = """
        Brain Waves Preset: \(preset.name)
        Category: \(preset.category.rawValue)
        Tags: \(preset.tags.joined(separator: ", "))

        Base Frequency: \(preset.baseFrequency) Hz
        Beat Frequency: \(preset.beatFrequency) Hz
        Duration: \(formatDuration(preset.duration))
        Waveform: \(preset.waveformType.rawValue)
        """

        if let rampConfig = preset.rampConfig, rampConfig.enabled {
            text += """


            Frequency Ramping:
            Type: \(rampConfig.rampType.rawValue)
            Curve: \(rampConfig.rampCurve.rawValue)
            Start: \(rampConfig.startFrequency) Hz
            End: \(rampConfig.endFrequency) Hz
            Duration: \(formatDuration(rampConfig.rampDuration))
            """
        }

        return .success(text)
    }

    private static func exportToText(_ preset: IsochronicTonePreset) -> Result<String, Error> {
        var text = """
        Brain Waves Preset: \(preset.name)
        Category: \(preset.category.rawValue)
        Tags: \(preset.tags.joined(separator: ", "))

        Carrier Frequency: \(preset.carrierFrequency) Hz
        Pulse Frequency: \(preset.pulseFrequency) Hz
        Duration: \(formatDuration(preset.duration))
        Waveform: \(preset.waveformType.rawValue)
        """

        if let rampConfig = preset.rampConfig, rampConfig.enabled {
            text += """


            Frequency Ramping:
            Type: \(rampConfig.rampType.rawValue)
            Curve: \(rampConfig.rampCurve.rawValue)
            Start: \(rampConfig.startFrequency) Hz
            End: \(rampConfig.endFrequency) Hz
            Duration: \(formatDuration(rampConfig.rampDuration))
            """
        }

        return .success(text)
    }

    private static func saveToTempFile(_ content: String, filename: String) -> Result<URL, Error> {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return .success(fileURL)
        } catch {
            return .failure(error)
        }
    }

    private static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(minutes) minutes"
        }
    }
}

enum ExportError: LocalizedError {
    case encodingFailed
    case invalidInput
    case fileCreationFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode preset data"
        case .invalidInput:
            return "Invalid input data"
        case .fileCreationFailed:
            return "Failed to create export file"
        }
    }
}
