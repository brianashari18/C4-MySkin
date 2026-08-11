//
//  FaceOutline.swift
//  C4-MySkin
//

import SwiftUI

struct FaceOutline: View {
    var body: some View {
        ZStack {
            Ellipse()
                .stroke(Color(.label), lineWidth: 2)

            VStack(spacing: 28) {
                EyeShape()
                EyeShape()
            }
            .offset(y: -40)

            NoseShape()
                .offset(y: 20)

            MouthShape()
                .offset(y: 80)
        }
    }
}

private struct EyeShape: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.label), lineWidth: 2)
                .frame(width: 44, height: 44)

            Circle()
                .fill(Color(.label))
                .frame(width: 16, height: 16)

            Path { path in
                path.move(to: CGPoint(x: 8, y: -28))
                path.addQuadCurve(to: CGPoint(x: 36, y: -28), control: CGPoint(x: 22, y: -40))
            }
            .stroke(Color(.label), lineWidth: 2)
            .frame(width: 44, height: 44)
        }
    }
}

private struct NoseShape: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: -8, y: 40))
            path.addQuadCurve(to: CGPoint(x: 8, y: 40), control: CGPoint(x: 0, y: 48))
        }
        .stroke(Color(.label), lineWidth: 2)
        .frame(width: 20, height: 50)
    }
}

private struct MouthShape: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: 60, y: 0), control: CGPoint(x: 30, y: 16))
        }
        .stroke(Color(.label), lineWidth: 2)
        .frame(width: 60, height: 20)
    }
}

#Preview {
    FaceOutline()
        .frame(width: 200, height: 260)
}
