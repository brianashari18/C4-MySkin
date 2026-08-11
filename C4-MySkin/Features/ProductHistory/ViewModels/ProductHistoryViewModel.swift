//
//  ProductHistoryViewModel.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI
import Combine

@MainActor
final class ProductHistoryViewModel: ObservableObject {

    @Published var selectedTab: HistoryTab = .picked
    @Published var pickedProducts: [PickedProductItem] = PickedProductItem.sampleList
    @Published var comparisonHistory: [ComparisonHistoryItem] = ComparisonHistoryItem.sampleList

    func selectTab(_ tab: HistoryTab) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            selectedTab = tab
        }
    }
}
