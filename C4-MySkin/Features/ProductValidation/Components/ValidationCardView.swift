//
//  ValidationCardView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Accordion card component matching the wireframe UI design.
/// Features a yellow top header with title and collapsible `v` chevron button.
/// Supports generic text items, rich checkmark items (✓ / ✗), key ingredients with descriptions,
/// benefit items, and concern items in both single and side-by-side comparison mode.
struct ValidationCardView<Content: View>: View {

    let title: String
    let content: Content

    @State private var isExpanded: Bool = true

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Accordion Yellow Header
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Spacer()
                    Text(title)
                        .font(Font.App.nunitoRounded(size: 16, weight: .bold))
                        .foregroundStyle(Color.App.darkBlue)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.App.darkBlue)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.App.sunnyYellow.opacity(0.85))
            }
            .buttonStyle(.plain)

            // MARK: - Collapsible Content
            if isExpanded {
                VStack(spacing: 0) {
                    content
                }
                .padding(.vertical, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.App.sunnyYellow.opacity(0.65), lineWidth: 1.5)
        )
        .shadow(color: Color.App.mediumBlue.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Convenience Initializers for Plain Text Lists
extension ValidationCardView where Content == AnyView {

    init(title: String, items: [String]) {
        self.init(title: title) {
            AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                            .foregroundStyle(Color.App.darkBlue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
            )
        }
    }

    init(title: String, items1: [String], items2: [String], highlightMatches: Bool = false) {
        let set1 = Set(items1.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        let set2 = Set(items2.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })

        self.init(title: title) {
            AnyView(
                HStack(alignment: .top, spacing: 0) {
                    // Left Column — Product 1
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(items1, id: \.self) { item in
                            let isMatched = highlightMatches && set2.contains(item.lowercased().trimmingCharacters(in: .whitespaces))
                            Text(item)
                                .font(Font.App.nunitoRounded(size: 14, weight: isMatched ? .bold : .medium))
                                .foregroundStyle(isMatched ? Color.App.darkBlue : (highlightMatches ? Color.gray.opacity(0.7) : Color.App.darkBlue))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Vertical Center Divider Line
                    Rectangle()
                        .fill(Color.App.sunnyYellow.opacity(0.6))
                        .frame(width: 1.5)

                    // Right Column — Product 2
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(items2, id: \.self) { item in
                            let isMatched = highlightMatches && set1.contains(item.lowercased().trimmingCharacters(in: .whitespaces))
                            Text(item)
                                .font(Font.App.nunitoRounded(size: 14, weight: isMatched ? .bold : .medium))
                                .foregroundStyle(isMatched ? Color.App.darkBlue : (highlightMatches ? Color.gray.opacity(0.7) : Color.App.darkBlue))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            )
        }
    }
}
