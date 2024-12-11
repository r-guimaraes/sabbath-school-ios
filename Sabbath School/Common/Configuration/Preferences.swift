/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
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

import Foundation
import UIKit
import PSPDFKitUI

extension UserDefaults {
    var account: Account? {
        get {
            if let data = data(forKey: Constants.DefaultKey.accountObject) {
                return try? JSONDecoder().decode(Account.self, from: data)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                set(data, forKey: Constants.DefaultKey.accountObject)
            } else {
                removeObject(forKey: Constants.DefaultKey.accountObject)
            }
        }
    }
    
    var language: QuarterlyLanguage? {
        get {
            if let data = data(forKey: Constants.DefaultKey.quarterlyLanguage) {
                return try? JSONDecoder().decode(QuarterlyLanguage.self, from: data)
            }
            return PreferencesShared.currentLanguage()
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                set(data, forKey: Constants.DefaultKey.quarterlyLanguage)
            } else {
                removeObject(forKey: Constants.DefaultKey.quarterlyLanguage)
            }
        }
    }
}

struct Preferences {
    static var userDefaults: UserDefaults {
        return PreferencesShared.userDefaults
    }
    
    static func currentLanguage() -> QuarterlyLanguage {
        return PreferencesShared.currentLanguage()
    }
    
    static func currentQuarterly() -> String {
        return PreferencesShared.currentQuarterly()
    }
    
    static func currentTheme() -> ReaderStyle.Theme {
        guard let rawTheme = Preferences.userDefaults.string(forKey: Constants.DefaultKey.readingOptionsTheme),
              let theme = ReaderStyle.Theme(rawValue: rawTheme) else {
            return .auto
        }
        return theme
    }
    
    static func darkModeEnable() -> Bool {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }
    
    static func reminderStatus() -> Bool {
        return Preferences.userDefaults.bool(forKey: Constants.DefaultKey.settingsReminderStatus)
    }

    static func reminderTime() -> String {
        guard let time = Preferences.userDefaults.string(forKey: Constants.DefaultKey.settingsReminderTime) else {
            return Constants.DefaultKey.settingsDefaultReminderTime
        }
        return time
    }
    
    static func getPreferredBibleVersionKey() -> String {
        return Constants.DefaultKey.preferredBibleVersion + Preferences.currentLanguage().code
    }
    
    static func getPdfPageTransition() -> PageTransition {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationPageTransition) != nil
        let pageTransition = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationPageTransition)
        return exists ? PageTransition(rawValue: UInt(pageTransition))! : PageTransition.scrollContinuous
    }
    
    static func getPdfPageMode() -> PageMode {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationPageMode) != nil
        let pageMode = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationPageMode)
        return exists ? PageMode(rawValue: UInt(pageMode))! : PageMode.single
    }
    
    static func getPdfScrollDirection() -> ScrollDirection {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationScrollDirection) != nil
        let scrollDirection = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationScrollDirection)
        return exists ? ScrollDirection(rawValue: UInt(scrollDirection))! : ScrollDirection.vertical
    }
    
    static func getPdfSpreadFitting() -> PDFConfiguration.SpreadFitting {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationSpreadFitting) != nil
        let spreadFitting = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationSpreadFitting)
        return exists ? PDFConfiguration.SpreadFitting(rawValue: spreadFitting)! : PDFConfiguration.SpreadFitting.fit
    }
}
