//
//  DemoConfiguration.swift
//  C4-MySkin
//

import Foundation

enum DemoConfiguration {
    static let isEnabled: Bool = {
        guard let url = Bundle.main.url(forResource: "demo", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
              ) as? [String: Any] else {
            return false
        }

        return plist["isDemoEnabled"] as? Bool ?? false
    }()
}
