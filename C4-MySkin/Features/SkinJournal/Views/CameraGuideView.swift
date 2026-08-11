//
//  CameraGuideView.swift
//  C4-MySkin
//

import SwiftUI

struct CameraGuideView: View {
    let onTakePhoto: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BackButton(action: onBack)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Text("Posisikan wajahmu\npada frame")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Spacer()

            FaceOutline()
                .frame(width: 260, height: 320)

            Text("Make sure you're in a proper\nlight condition for best results")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.top, 32)

            Spacer()

            Button(action: onTakePhoto) {
                HStack(spacing: 8) {
                    Text("Take Photo")
                        .font(.body.weight(.semibold))
                    Image(systemName: "camera.fill")
                }
                .foregroundStyle(Color(.label))
                .frame(minWidth: 200, minHeight: 56)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 40)
        }
    }
}


#Preview {
    CameraGuideView(onTakePhoto: {}, onBack: {})
}
