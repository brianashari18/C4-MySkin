//
//  MascotBubble.swift
//  C4-MySkin
//

import SwiftUI

struct MascotBubble: View {
    let message: String

    var body: some View {
        ZStack {
            SpeechBubbleShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)

            SpeechBubbleShape()
                .stroke(Color(red: 0.40, green: 0.40, blue: 0.40), lineWidth: 3.5)

            Text(message)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.15))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 30) // Space above tail inset
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SpeechBubbleShape: Shape {
    let cornerRadius: CGFloat = 20
    let tailWidth: CGFloat = 18
    let tailHeight: CGFloat = 16
    let tailOffsetFromLeft: CGFloat = 34

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = cornerRadius
        let bodyMaxY = max(minY(for: rect) + r * 2, rect.maxY - tailHeight)
        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY

        let tailBaseRight = minX + tailOffsetFromLeft + tailWidth
        let tailTipX = minX + tailOffsetFromLeft - 6
        let tailTipY = rect.maxY
        let tailBaseLeft = minX + tailOffsetFromLeft

        // Start top-left after corner
        path.move(to: CGPoint(x: minX + r, y: minY))

        // Top edge
        path.addLine(to: CGPoint(x: maxX - r, y: minY))
        // Top-Right corner
        path.addArc(center: CGPoint(x: maxX - r, y: minY + r), radius: r, startAngle: .radians(-.pi / 2), endAngle: .radians(0), clockwise: false)

        // Right edge
        path.addLine(to: CGPoint(x: maxX, y: bodyMaxY - r))
        // Bottom-Right corner
        path.addArc(center: CGPoint(x: maxX - r, y: bodyMaxY - r), radius: r, startAngle: .radians(0), endAngle: .radians(.pi / 2), clockwise: false)

        // Bottom edge right of tail
        path.addLine(to: CGPoint(x: tailBaseRight, y: bodyMaxY))

        // Tail pointing down-left
        path.addLine(to: CGPoint(x: tailTipX, y: tailTipY))
        path.addLine(to: CGPoint(x: tailBaseLeft, y: bodyMaxY))

        // Bottom edge left of tail
        path.addLine(to: CGPoint(x: minX + r, y: bodyMaxY))
        // Bottom-Left corner
        path.addArc(center: CGPoint(x: minX + r, y: bodyMaxY - r), radius: r, startAngle: .radians(.pi / 2), endAngle: .radians(.pi), clockwise: false)

        // Left edge
        path.addLine(to: CGPoint(x: minX, y: minY + r))
        // Top-Left corner
        path.addArc(center: CGPoint(x: minX + r, y: minY + r), radius: r, startAngle: .radians(.pi), endAngle: .radians(3 * .pi / 2), clockwise: false)

        path.closeSubpath()
        return path
    }

    private func minY(for rect: CGRect) -> CGFloat {
        rect.minY
    }
}

#Preview {
    MascotBubble(message: "Purging berbeda\ndengan breakout\nloh !")
        .padding()
}

