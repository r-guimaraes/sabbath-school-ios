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
import Foundation

protocol StyleTemplate {
    var textKeyPath: KeyPath<Style, TextStyle?> { get set }
    var blockStyleKeyPath: KeyPath<Style, BlockStyle?> { get set }
    
    var textSizeEnabled: Bool { get set }
    var textSizeDefault: CGFloat { get set }
    var textSizePoints: (_ size: TextStyleSize) -> CGFloat { get set }
    
    var textColorEnabled: Bool { get set }
    var textColorDefault: Color { get set }
    
    var textTypefaceEnabled: Bool { get set }
    var textTypefaceDefault: String { get set }
    
    var textAlignmentEnabled: Bool { get set }
    var textAlignmentDefault: TextAlignment { get set }
    var textAlignmentFunc: (_ alignment: TextStyleAlignment) -> TextAlignment { get set }
    
    var textOffsetEnabled: Bool { get set }
    var textOffsetDefault: CGFloat { get set }
    var textOffsetFunc: (_ offset: TextStyleOffset) -> CGFloat { get set }
    
    var textColorThemeOverride: Bool { get set }
    var textLinksEnabled: Bool { get set }
    var textInlineStyleEnabled: Bool { get set }
    
    var paddingEnabled: Bool { get set }
    var paddingDefault: EdgeInsets { get set }
    var paddingFunc: (_ spacing: BlockStyleSpacing) -> CGFloat { get set }
    
    var backgroundColorEnabled: Bool { get set }
    var backgroundColorDefault: Color { get set }
    
    var backgroundImageEnabled: Bool { get set }
    var backgroundImageDefault: URL? { get set }
    
    var roundedCornersEnabled: Bool { get set }
    var roundedCornersDefault: CGFloat { get set }
    var roundedCornersEnabledValue: CGFloat { get set }
}
