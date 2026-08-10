//
//  ScanFrameOverlay.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// The four-corner bracket scan frame shown on the camera scanner screen.
struct ScanFrameOverlay: View {

    // MARK: - Animation
    @State private var pulsing: Bool = false

    private let cornerLength: CGFloat = 36
    private let lineWidth: CGFloat = 7
    private let cornerRadius: CGFloat = 14
    private let frameSize: CGFloat = 220

    var body: some View {
        ZStack {
            // Subtle animated inner glow
            RoundedRectangle(cornerRadius: cornerRadius + 4)
                .stroke(Color.white.opacity(pulsing ? 0.12 : 0.04), lineWidth: 2)
                .frame(width: frameSize + 10, height: frameSize + 10)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: pulsing
                )

            // Four corners
            ScanCorners(
                cornerLength: cornerLength,
                lineWidth: lineWidth,
                cornerRadius: cornerRadius,
                size: frameSize
            )
        }
        .onAppear { pulsing = true }
    }
}

// MARK: - ScanCorners Shape
private struct ScanCorners: View {
    let cornerLength: CGFloat
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let size: CGFloat

    var body: some View {
        Canvas { context, _ in
            let rect = CGRect(
                x: lineWidth / 2,
                y: lineWidth / 2,
                width: size - lineWidth,
                height: size - lineWidth
            )
            let r = cornerRadius
            let l = cornerLength

            context.stroke(
                cornerPath(in: rect, radius: r, length: l),
                with: .color(.black),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: size, height: size)
    }

    private func cornerPath(in rect: CGRect, radius: CGFloat, length: CGFloat) -> Path {
        var path = Path()

        let minX = rect.minX, maxX = rect.maxX
        let minY = rect.minY, maxY = rect.maxY

        // Top-left corner
        path.move(to: CGPoint(x: minX, y: minY + length))
        path.addLine(to: CGPoint(x: minX, y: minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: minX + radius, y: minY),
            control: CGPoint(x: minX, y: minY)
        )
        path.addLine(to: CGPoint(x: minX + length, y: minY))

        // Top-right corner
        path.move(to: CGPoint(x: maxX - length, y: minY))
        path.addLine(to: CGPoint(x: maxX - radius, y: minY))
        path.addQuadCurve(
            to: CGPoint(x: maxX, y: minY + radius),
            control: CGPoint(x: maxX, y: minY)
        )
        path.addLine(to: CGPoint(x: maxX, y: minY + length))

        // Bottom-right corner
        path.move(to: CGPoint(x: maxX, y: maxY - length))
        path.addLine(to: CGPoint(x: maxX, y: maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: maxX - radius, y: maxY),
            control: CGPoint(x: maxX, y: maxY)
        )
        path.addLine(to: CGPoint(x: maxX - length, y: maxY))

        // Bottom-left corner
        path.move(to: CGPoint(x: minX + length, y: maxY))
        path.addLine(to: CGPoint(x: minX + radius, y: maxY))
        path.addQuadCurve(
            to: CGPoint(x: minX, y: maxY - radius),
            control: CGPoint(x: minX, y: maxY)
        )
        path.addLine(to: CGPoint(x: minX, y: maxY - length))

        return path
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.opacity(0.5)
        ScanFrameOverlay()
    }
    .frame(width: 320, height: 320)
}
