/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SwiftUI

struct ReaderStyle {
    enum Theme: String {
        case light
        case sepia
        case dark
        case auto

//        static var items: [Theme] {
//            return [
//                .light,
//                .sepia,
//                .dark,
//                .auto
//            ]
//        }
//
//        var backgroundColor: UIColor {
//            switch self {
//            case .light: return AppStyle.Reader.Color.white
//            case .sepia: return AppStyle.Reader.Color.sepia
//            case .dark: return AppStyle.Reader.Color.dark
//            case .auto: return AppStyle.Reader.Color.auto
//            }
//        }
//
//        var navBarColor: UIColor {
//            switch self {
//            case .light: return AppStyle.Reader.Color.white
//            case .sepia: return AppStyle.Reader.Color.sepia
//            case .dark: return AppStyle.Reader.Color.dark
//            case .auto: return AppStyle.Reader.Color.auto
//            }
//        }
//
//        var navBarTextColor: UIColor {
//            switch self {
//            case .light: return .black
//            case .sepia: return .black
//            case .dark: return .white
//            case .auto:
//                return Preferences.darkModeEnable() ? UIColor.white:UIColor.black
//            }
//        }
    }

    enum Typeface: String {
        case andada
        case lato
        case ptSerif = "pt-serif"
        case ptSans = "pt-sans"

//        static var items: [Typeface] {
//            return [
//                .andada,
//                .lato,
//                .ptSerif,
//                .ptSans
//            ]
//        }
    }

    enum Size: String, CaseIterable {
        case tiny
        case small
        case medium
        case large
        case huge

//        static var items: [Size] {
//            return [
//                .tiny,
//                .small,
//                .medium,
//                .large,
//                .huge
//            ]
//        }
    }

//    enum Highlight: String {
//        case green
//        case blue
//        case orange
//        case yellow
//
//        static var items: [Highlight] {
//            return [
//                .green,
//                .blue,
//                .orange,
//                .yellow
//            ]
//        }
//    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: ReaderStyle.Theme = .auto
    @Published var backgroundColor: Color = Preferences.darkModeEnable() ? .black : .white
    @Published var currentSize: ReaderStyle.Size = .medium
    @Published var currentTypeface: ReaderStyle.Typeface = .lato

    init() {
        if let savedTheme = Preferences.userDefaults.string(forKey: Constants.DefaultKey.readingOptionsTheme),
           let theme = ReaderStyle.Theme(rawValue: savedTheme)
        {
            currentTheme = theme
            backgroundColor = getBackgroundColor()
        }
        
        if let savedSize = Preferences.userDefaults.string(forKey: Constants.DefaultKey.readingOptionsSize),
           let size = ReaderStyle.Size(rawValue: savedSize)
        {
            currentSize = size
        }
        
        if let savedTypeface = Preferences.userDefaults.string(forKey: Constants.DefaultKey.readingOptionsTypeface),
           let typeface = ReaderStyle.Typeface(rawValue: savedTypeface)
        {
            currentTypeface = typeface
        }
    }

    func setTheme(to newTheme: ReaderStyle.Theme) {
        currentTheme = newTheme
        backgroundColor = getBackgroundColor()
        Preferences.userDefaults.set(newTheme.rawValue, forKey: Constants.DefaultKey.readingOptionsTheme)
    }
    
    func setSize(to newSize: ReaderStyle.Size) {
        currentSize = newSize
        Preferences.userDefaults.set(newSize.rawValue, forKey: Constants.DefaultKey.readingOptionsSize)
    }
    
    func setTypeface(to newTypeface: ReaderStyle.Typeface) {
        currentTypeface = newTypeface
        Preferences.userDefaults.set(newTypeface.rawValue, forKey: Constants.DefaultKey.readingOptionsTypeface)
    }
    
    func increaseSize() {
        switch currentSize {
        case .tiny:
            setSize(to: .small)
        case .small:
            setSize(to: .medium)
        case .medium:
            setSize(to: .large)
        case .large:
            setSize(to: .huge)
        case .huge:
            return
        }
    }
    
    func decreaseSize() {
        switch currentSize {
        case .tiny:
            return
        case .small:
            setSize(to: .tiny)
        case .medium:
            setSize(to: .small)
        case .large:
            setSize(to: .medium)
        case .huge:
            setSize(to: .large)
        }
    }
    
    func getBackgroundColor() -> Color {
        switch currentTheme {
        case .light: return .white
        case .sepia: return Color(hex: "#FBF0D9")
        case .dark: return .black
        case .auto: return Preferences.darkModeEnable() ? .black : .white
        }
    }
    
    func getTextColor() -> Color {
        switch currentTheme {
        case .light: return .black
        case .sepia: return Color(hex: "#5b4636")
        case .dark: return .white
        case .auto: return Preferences.darkModeEnable() ? .white : .black
        }
    }
    
    func getSizeNumber () -> Int {
        switch currentSize {
        case .tiny: return 1
        case .small: return 2
        case .medium: return 3
        case .large: return 4
        case .huge: return 5
        }
    }
}
