//
//  Font+Theme.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

extension Font {
    /// App-specific typography based on the Moodboard UI Design
    struct App {
        
        /// Generates the Nunito Rounded font at a specific size and weight.
        ///
        /// - Important: For this to render properly, you must:
        /// 1. Download the Nunito Rounded `.ttf` files.
        /// 2. Drag them into your Xcode project (ensure "Copy items if needed" is checked and add to target).
        /// 3. Add the font file names to your `Info.plist` under the "Fonts provided by application" key (`UIAppFonts`).
        static func nunitoRounded(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            let weightString: String
            
            // Map SwiftUI Font.Weight to the typical font file naming convention
            switch weight {
            case .black, .heavy: weightString = "Black"
            case .bold: weightString = "Bold"
            case .semibold: weightString = "SemiBold"
            case .medium: weightString = "Medium"
            case .light: weightString = "Light"
            case .thin, .ultraLight: weightString = "ExtraLight"
            default: weightString = "Regular"
            }
            
            return .custom("NunitoRounded-\(weightString)", size: size)
        }
    }
}
