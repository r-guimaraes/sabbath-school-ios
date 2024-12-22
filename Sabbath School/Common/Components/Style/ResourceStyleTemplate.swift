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

class ResourceTitleStyleTemplate: StyleTemplate {
    var textKeyPath: KeyPath<Style, TextStyle?>
    var blockStyleKeyPath: KeyPath<Style, BlockStyle?>
    
    var textSizeEnabled: Bool
    var textSizeDefault: CGFloat
    var textSizePoints: (_ size: TextStyleSize) -> CGFloat
    
    var textColorEnabled: Bool
    var textColorDefault: Color
    
    var textTypefaceEnabled: Bool
    var textTypefaceDefault: String
    
    var textAlignmentEnabled: Bool
    var textAlignmentDefault: TextAlignment
    var textAlignmentFunc: (_ alignment: TextStyleAlignment) -> TextAlignment
    
    var textOffsetEnabled: Bool
    var textOffsetDefault: CGFloat
    var textOffsetFunc: (TextStyleOffset) -> CGFloat
    
    var textColorThemeOverride: Bool
    var textLinksEnabled: Bool
    
    var textInlineStyleEnabled: Bool
    
    var paddingEnabled: Bool
    var paddingDefault: EdgeInsets
    var paddingFunc: (_ spacing: BlockStyleSpacing) -> CGFloat
    
    var backgroundColorEnabled: Bool
    var backgroundColorDefault: Color
    
    var backgroundImageEnabled: Bool
    var backgroundImageDefault: URL?
    
    var roundedCornersEnabled: Bool
    var roundedCornersDefault: CGFloat
    var roundedCornersEnabledValue: CGFloat
    
    init () {
        self.textKeyPath = \.resource?.title?.text
        self.blockStyleKeyPath = \.blocks?.inline?.all
        
        self.textSizeEnabled = true
        self.textSizeDefault = 30.0
        
        self.textColorEnabled = true
        self.textColorDefault = .white
        
        self.textTypefaceEnabled = true
        self.textTypefaceDefault = "Lato-Black"
        
        self.textAlignmentEnabled = false
        self.textAlignmentDefault = .leading
        self.textAlignmentFunc = { alignment in
            return .leading
        }
        
        self.textOffsetEnabled = false
        self.textOffsetDefault = 0.0
        self.textOffsetFunc = { offset in
            return 0.0
        }
        
        self.textColorThemeOverride = false
        self.textLinksEnabled = false
        
        self.textInlineStyleEnabled = true
        
        self.textSizePoints = { size in
            switch size {
            case .xs:
                return 22
            case .sm:
                return 26
            case .base:
                return 30
            case .lg:
                return 34
            case .xl:
                return 42
            }
        }
        
        self.paddingEnabled = false
        self.paddingDefault = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        self.paddingFunc = { spacing in
            return 0
        }
        
        self.backgroundColorEnabled = false
        self.backgroundColorDefault = .clear
        
        self.backgroundImageEnabled = false
        self.backgroundImageDefault = nil
        self.roundedCornersEnabled = false
        self.roundedCornersDefault = 0
        self.roundedCornersEnabledValue = 0
    }
}

class ResourceSubtitleStyleTemplate: ResourceTitleStyleTemplate {
    override init () {
        super.init()
        self.textKeyPath = \.resource?.subtitle?.text
        
        self.textSizeDefault = 13
        self.textColorDefault = .white.opacity(0.7)
        self.textTypefaceDefault = "Lato-Bold"
        
        self.textSizePoints = { size in
            switch size {
            case .xs:
                return 9
            case .sm:
                return 11
            case .base:
                return 13
            case .lg:
                return 15
            case .xl:
                return 17
            }
        }
    }
}

class ResourceDescriptionStyleTemplate: ResourceTitleStyleTemplate {
    override init () {
        super.init()
        self.textKeyPath = \.resource?.description?.text
        
        self.textSizeDefault = 15
        self.textColorDefault = .white
        self.textTypefaceDefault = "Lato-Medium"
        
        self.textSizePoints = { size in
            switch size {
            case .xs:
                return 11
            case .sm:
                return 13
            case .base:
                return 15
            case .lg:
                return 17
            case .xl:
                return 19
            }
        }
    }
}
