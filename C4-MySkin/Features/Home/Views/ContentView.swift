//
//  ContentView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 07/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: viewModel.iconName)
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text(viewModel.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(viewModel.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
