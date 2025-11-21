//
//  CategorySelector.swift
//  BrainWaves
//
//  Created by Brain Waves on 2024.
//

import SwiftUI

struct CategorySelector: View {
    @Binding var selectedCategory: AppConstants.PresetCategory
    @Binding var tags: [String]
    @State private var isExpanded = false
    @State private var newTag = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: selectedCategory.icon)
                    .foregroundColor(colorForCategory(selectedCategory))
                Text("Category & Tags")
                    .font(.headline)
                Spacer()
                Text(selectedCategory.rawValue)
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

            if isExpanded {
                VStack(spacing: 16) {
                    // Category Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(AppConstants.PresetCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                    HapticManager.shared.playSelection()
                                }
                            }
                        }
                    }

                    // Tags Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        // Display existing tags
                        if !tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    TagChip(text: tag) {
                                        tags.removeAll { $0 == tag }
                                        HapticManager.shared.playSelection()
                                    }
                                }
                            }
                        }

                        // Add new tag
                        HStack {
                            TextField("Add tag", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)

                            Button(action: {
                                let trimmed = newTag.trimmingCharacters(in: .whitespaces)
                                if !trimmed.isEmpty && !tags.contains(trimmed) {
                                    tags.append(trimmed)
                                    newTag = ""
                                    HapticManager.shared.playSelection()
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                            }
                            .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                .padding(.top, 8)
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

    private func colorForCategory(_ category: AppConstants.PresetCategory) -> Color {
        switch category.color {
        case "indigo": return .indigo
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "yellow": return .yellow
        case "cyan": return .cyan
        default: return .gray
        }
    }
}

struct CategoryButton: View {
    let category: AppConstants.PresetCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : colorForCategory(category))
                Text(category.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? colorForCategory(category) : Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func colorForCategory(_ category: AppConstants.PresetCategory) -> Color {
        switch category.color {
        case "indigo": return .indigo
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "yellow": return .yellow
        case "cyan": return .cyan
        default: return .gray
        }
    }
}

struct TagChip: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue)
        .cornerRadius(12)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    CategorySelector(
        selectedCategory: .constant(.meditation),
        tags: .constant(["theta", "mindfulness", "calm"])
    )
    .padding()
}
