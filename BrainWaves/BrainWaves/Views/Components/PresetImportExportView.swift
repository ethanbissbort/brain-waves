//
//  PresetImportExportView.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct PresetShareButton<T>: View where T: Identifiable {
    let preset: T
    let exportAction: (T) -> Result<URL, Error>
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        Button(action: {
            switch exportAction(preset) {
            case .success(let url):
                shareURL = url
                showShareSheet = true
                HapticManager.shared.playSelection()
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.blue)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Export Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

struct PresetImportButton: View {
    @Binding var isPresented: Bool
    let importType: PresetImportType

    enum PresetImportType {
        case binaural
        case isochronic
    }

    var body: some View {
        Button(action: {
            isPresented = true
            HapticManager.shared.playSelection()
        }) {
            Label("Import Preset", systemImage: "square.and.arrow.down")
        }
    }
}

struct PresetImportSheet: View {
    @Binding var isPresented: Bool
    let onImport: (String) -> Void
    @State private var importText = ""
    @State private var showFilePicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Import Preset")
                    .font(.headline)

                Text("Paste preset JSON below or import from file")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextEditor(text: $importText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                HStack(spacing: 16) {
                    Button(action: {
                        showFilePicker = true
                    }) {
                        Label("Import File", systemImage: "doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: {
                        if let clipboardString = UIPasteboard.general.string {
                            importText = clipboardString
                            HapticManager.shared.playSelection()
                        }
                    }) {
                        Label("Paste", systemImage: "doc.on.clipboard")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Button(action: {
                    onImport(importText)
                    isPresented = false
                    HapticManager.shared.playSelection()
                }) {
                    Label("Import", systemImage: "arrow.down.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(importText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Import Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.json, .text],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    do {
                        let content = try String(contentsOf: url, encoding: .utf8)
                        importText = content
                        HapticManager.shared.playSelection()
                    } catch {
                        Logger.shared.error(error)
                    }
                }
            case .failure(let error):
                Logger.shared.error(error)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

#Preview {
    PresetImportSheet(isPresented: .constant(true)) { jsonString in
        print("Imported: \(jsonString)")
    }
}
