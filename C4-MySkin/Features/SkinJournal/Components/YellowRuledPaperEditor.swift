//
//  YellowRuledPaperEditor.swift
//  C4-MySkin
//

import SwiftUI

struct YellowRuledPaperEditor: View {
    @Binding var text: String

    private let lineSpacing: CGFloat = 14
    private let fontSize: CGFloat = 16
    private let lineStep: CGFloat = 36 // Vertical distance between lines

    private var calculatedLines: Int {
        let count = text.components(separatedBy: .newlines).count
        let charCount = text.count
        let estimatedWrappedLines = max(1, charCount / 30)
        return max(2, max(count, estimatedWrappedLines))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Warm yellow pastel background
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))

            // Dynamic notebook ruled lines
            VStack(spacing: 0) {
                Spacer().frame(height: 38)
                ForEach(0..<calculatedLines, id: \.self) { _ in
                    Divider()
                        .background(Color(red: 0.82, green: 0.72, blue: 0.52).opacity(0.6))
                    Spacer().frame(height: lineStep - 1)
                }
            }
            .padding(.horizontal, 20)

            // TextEditor overlay
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .lineSpacing(lineSpacing)
                .tint(Color(red: 0.0, green: 0.5, blue: 1.0)) // Blue cursor matching design
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .frame(minHeight: max(120, CGFloat(calculatedLines) * lineStep + 30))
        .animation(.easeInOut(duration: 0.2), value: calculatedLines)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    YellowRuledPaperEditor(text: .constant(""))
        .padding()
}
