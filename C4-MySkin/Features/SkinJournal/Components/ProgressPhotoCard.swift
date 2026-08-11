//
//  ProgressPhotoCard.swift
//  C4-MySkin
//

import SwiftUI

struct ProgressPhotoCard: View {
    let imageName: String?

    init(imageName: String? = nil) {
        self.imageName = imageName
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(red: 0.84, green: 0.84, blue: 0.84))
                    .aspectRatio(1, contentMode: .fit)

                if let imageName = imageName, !imageName.isEmpty, let uiImage = CameraViewModel.loadImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                } else {
                    VStack(spacing: 4) {
                        Text("no photos")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color(red: 0.20, green: 0.38, blue: 0.56))
                        Text("yet")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color(red: 0.20, green: 0.38, blue: 0.56))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }
}

#Preview {
    ProgressPhotoCard()
        .padding()
}


