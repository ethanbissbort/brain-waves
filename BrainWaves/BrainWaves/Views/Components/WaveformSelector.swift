//
//  WaveformSelector.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct WaveformSelector: View {
    @Binding var selectedWaveform: AppConstants.WaveformType
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: selectedWaveform.icon)
                    .foregroundColor(.blue)
                Text("Waveform")
                    .font(.headline)
                Spacer()
                Text(selectedWaveform.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                    HapticManager.shared.playSelection()
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            }

            // Description
            if isExpanded {
                Text(selectedWaveform.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                // Waveform options
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(AppConstants.WaveformType.allCases, id: \.self) { waveform in
                        WaveformButton(
                            waveform: waveform,
                            isSelected: selectedWaveform == waveform
                        ) {
                            selectedWaveform = waveform
                            HapticManager.shared.playSelection()
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct WaveformButton: View {
    let waveform: AppConstants.WaveformType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: waveform.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                Text(waveform.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    WaveformSelector(selectedWaveform: .constant(.sine))
        .padding()
}
