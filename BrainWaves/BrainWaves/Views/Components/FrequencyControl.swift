//
//  FrequencyControl.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct FrequencyControl: View {
    let label: String
    @Binding var frequency: Double
    let range: ClosedRange<Double>
    let unit: String

    @State private var textValue: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f %@", frequency, unit))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Slider(value: $frequency, in: range, step: 0.5)
                .accentColor(.blue)

            HStack {
                Text(String(format: "%.1f", range.lowerBound))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                TextField("Enter value", text: $textValue)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
                    .focused($isTextFieldFocused)
                    .onChange(of: textValue) { newValue in
                        updateFrequencyFromText(newValue)
                    }
                    .onAppear {
                        textValue = String(format: "%.1f", frequency)
                    }
                    .onChange(of: frequency) { newValue in
                        if !isTextFieldFocused {
                            textValue = String(format: "%.1f", newValue)
                        }
                    }

                Spacer()

                Text(String(format: "%.1f", range.upperBound))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func updateFrequencyFromText(_ text: String) {
        if let value = Double(text) {
            frequency = min(max(value, range.lowerBound), range.upperBound)
        }
    }
}

struct FrequencyControl_Previews: PreviewProvider {
    static var previews: some View {
        FrequencyControl(
            label: "Base Frequency",
            frequency: .constant(200),
            range: 100...500,
            unit: "Hz"
        )
        .padding()
    }
}
